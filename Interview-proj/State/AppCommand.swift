//
//  AppCommand.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import Combine
import CoreData

protocol AppCommand {
	func execute(in store: Store)
}


struct LoadEndpointCommand: AppCommand {
	
	func execute(in store: Store) {
		guard let history = CoredataContentStore.default.loadLastHistory().first else {
			return
		}
		let ep = CoredataContentStore.default.loadRecentEndpoint(history: history)
		store.dispatch(.loadEndpointComplete(.success(ep)))
	}
}

struct LoadHistoryCommand: AppCommand {
	func execute(in store: Store) {
		let history = CoredataContentStore.default.loadReqHistory()
		store.dispatch(.loadHistoryComplete(.success(history)))
	}
}

struct RequestCommand: AppCommand {
	func execute(in store: Store) {
		let token = SubscriptionToken()
		
		GithubAPI().get()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { (complete) in
				if case .failure(let error) = complete {
					store.dispatch(.loadEndpointComplete(.failure(error)))
				}
				token.unseal()
			}, receiveValue: { ep in
				store.dispatch(.loadEndpoint)
			})
			.seal(in: token)
	}
}


class SubscriptionToken {
	var cancellable: AnyCancellable?
	func unseal() { cancellable = nil }
}

extension AnyCancellable {
	func seal(in token: SubscriptionToken) {
		token.cancellable = self
	}
}

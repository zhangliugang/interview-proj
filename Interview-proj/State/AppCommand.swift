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
		
		let fetchHistory: NSFetchRequest<History> = History.fetchRequest()
		fetchHistory.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: false)]
		fetchHistory.fetchLimit = 1
		
		
		let ctx = CoreDataManager.shared.managedObjectContext
		
		let asyncFetchHistory = NSAsynchronousFetchRequest(fetchRequest: fetchHistory) { result in
			guard let history = result.finalResult?.first else { return }
			
			let fetchEndpoint: NSFetchRequest<Endpoint> = Endpoint.fetchRequest()
			fetchEndpoint.sortDescriptors = [NSSortDescriptor(keyPath: \Endpoint.name, ascending: true)]
			fetchEndpoint.predicate = NSPredicate(format: "from = %@", history)
			
			let asyncFetchEndpoint = NSAsynchronousFetchRequest(fetchRequest: fetchEndpoint) { result in
				store.dispatch(.loadEndpointComplete(.success(result.finalResult ?? [])))
			}
			
			do {
				try ctx.execute(asyncFetchEndpoint)
				
			} catch {
				store.dispatch(.loadEndpointComplete(.failure(.databaseError)))
			}
		}
		
		do {
			try ctx.execute(asyncFetchHistory)
		} catch {
			
			store.dispatch(.loadEndpointComplete(.failure(.databaseError)))
			
		}

	}
}

struct LoadHistoryCommand: AppCommand {
	func execute(in store: Store) {
		let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: false)]
		let ctx = CoreDataManager.shared.managedObjectContext

		let asyncRequst = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
			store.dispatch(.loadHistoryComplete(.success(result.finalResult ?? [])))
		}
		do {
			try ctx.execute(asyncRequst)
		} catch {
			store.dispatch(.loadHistoryComplete(.failure(.databaseError)))
		}
		
	}
}

struct RequestCommand: AppCommand {
	func execute(in store: Store) {
		let token = SubscriptionToken()
		
		let req = URLRequest(url: URL(string: "https://api.github.com/")!)
		let conf = URLSessionConfiguration.default
		conf.requestCachePolicy = .reloadIgnoringCacheData
		URLSession(configuration: conf).dataTaskPublisher(for: req)
			.map { $0.data }
			.mapError { _ in AppError.networkfail }
			.sink(receiveCompletion: { complete in
				if case .failure(let error) = complete {
					store.dispatch(.loadEndpointComplete(.failure(error)))
				}
				token.unseal()
			}, receiveValue: { data in
				do {
					let ctx = CoreDataManager.shared.backgroundObjectContext()
					let history = History(context: ctx)
					history.date = Date()
					history.success = true

					let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,String>

					var eps = [Endpoint]()
					for (key, value) in json {
						let endpoint = Endpoint(context: ctx)
						endpoint.name = key
						endpoint.value = value
						endpoint.from = history
						eps.append(endpoint)
					}

					CoreDataManager.shared.saveContext(ctx)

					DispatchQueue.main.async {
						store.dispatch(.loadEndpoint)
					}
					
				} catch {
					DispatchQueue.main.async {
						store.dispatch(.showError(.unknown))
					}
				}
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

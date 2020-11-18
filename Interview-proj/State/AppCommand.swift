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
		
		let fetchEndpoint: NSFetchRequest<Endpoint> = Endpoint.fetchRequest()
		fetchEndpoint.sortDescriptors = [NSSortDescriptor(keyPath: \Endpoint.name, ascending: true)]
		let ctx = CoreDataManager.shared.managedObjectContext
		ctx.perform {
			do {
				guard let history = try ctx.fetch(fetchHistory).first else { return }
				
				fetchEndpoint.predicate = NSPredicate(format: "from = %@", history)
				let ep = try ctx.fetch(fetchEndpoint)
				
				store.dispatch(.loadEndpointComplete(.success(ep)))
			} catch {
				
				store.dispatch(.loadEndpointComplete(.failure(.databaseError)))
				
			}
		}
				
			
		
	}
}

struct LoadHistoryCommand: AppCommand {
	func execute(in store: Store) {
		let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: false)]
		let ctx = CoreDataManager.shared.managedObjectContext
		ctx.perform {
			do {
				let historeis = try ctx.fetch(fetchRequest)
				store.dispatch(.loadHistoryComplete(.success(historeis)))
			} catch {
				store.dispatch(.loadHistoryComplete(.failure(.databaseError)))
			}
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
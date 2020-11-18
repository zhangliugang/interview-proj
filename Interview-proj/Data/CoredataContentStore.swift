//
//  CoredataContentStore.swift
//  Interview-proj
//
//  Created by August on 11/18/20.
//

import Combine
import CoreData
import Foundation

class CoredataContentStore {
	static let `default` = CoredataContentStore()
	
	func loadRecentEndpoint(history: History) -> [Endpoint] {
		let predicate = NSPredicate(format: "from = %@", history)
		let sort = NSSortDescriptor(keyPath: \Endpoint.name, ascending: true)
		return load(by: predicate, descriptors: [sort])
	}
	
	func loadReqHistory() -> [History] {
		let sort = NSSortDescriptor(keyPath: \History.date, ascending: false)
		return load(descriptors: [sort])
	}
	
	func loadLastHistory() -> [History] {
		let sort = NSSortDescriptor(keyPath: \History.date, ascending: false)
		return load(limit: 1, descriptors: [sort])
	}

	
	private func load<T: NSManagedObject>(
		by predicate: NSPredicate? = nil,
		limit: Int? = nil,
		descriptors: [NSSortDescriptor]? = nil) -> [T] {
		
		
		let context = CoreDataManager.shared.managedObjectContext
		
		let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = descriptors
		if let limit = limit {
			fetchRequest.fetchLimit = limit
		}


		do {
			return try context.fetch(fetchRequest)
		}
		catch {
			return []
		}
		
	}
}

//struct PerformPublisher<Output>: Publisher {
//	typealias Failure = Error
//	
//	let managedObjectContext: NSManagedObjectContext
//
//	let block: () throws -> Output
//	
//	func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
//		let subscription = PerformSubscription<Output>(
//					subscriber: AnySubscriber(subscriber),
//					publisher: self)
//				subscriber.receive(subscription: subscription)
//	}
//}
//
//private final class PerformSubscription<Output>: Subscription, CustomStringConvertible {
//	private var subscriber: AnySubscriber<Output, Error>?
//	private let publisher: PerformPublisher<Output>
//	
//	var description: String { "PerformPublisher" } // for publisher print operator
//	
//	init(subscriber: AnySubscriber<Output, Error>,
//		 publisher: PerformPublisher<Output>
//	) {
//		self.subscriber = subscriber
//		self.publisher = publisher
//	}
//
//	func request(_ demand: Subscribers.Demand) {
//		guard demand != .none, subscriber != nil else { return }
//
//		publisher.managedObjectContext.perform {
//			guard let subscriber = self.subscriber else { return }
//			do {
//				let output = try self.publisher.block()
//				_ = subscriber.receive(output)
//				subscriber.receive(completion: .finished)
//			} catch {
//				subscriber.receive(completion: .failure(error))
//			}
//		}
//	}
//
//	func cancel() {
//		subscriber = nil
//	}
//}
//
//extension NSManagedObjectContext {
//	public func fetchPublisher<T>(
//			_ fetchRequest: NSFetchRequest<T>
//		) -> AnyPublisher<[T], Error> where T: NSFetchRequestResult {
//			PerformPublisher<[T]>(managedObjectContext: self) {
//				try fetchRequest.execute()
//			}.eraseToAnyPublisher()
//		}
//}

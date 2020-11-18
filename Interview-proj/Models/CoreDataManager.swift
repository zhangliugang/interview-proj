//
//  CoreDataManager.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import Foundation
import CoreData

class CoreDataManager {
	static let shared = CoreDataManager()
	
	let model = "CoreData"
	let identifier = "cn.gugu.Interview-proj"
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let dataKitBundle = Bundle.main
		let modelUrl = dataKitBundle.url(forResource: self.model, withExtension: "momd")!
		let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl)!
		let persistenStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		
		let fileManager = FileManager.default
		let storeName = "\(self.model).sqlite"
		let documentDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let persistentStoreUrl = documentDirectoryUrl.appendingPathComponent(storeName)
		
		do {
		  let options = [
			NSMigratePersistentStoresAutomaticallyOption: true,
			NSInferMappingModelAutomaticallyOption: true
		  ]
		  
		  try persistenStoreCoordinator.addPersistentStore(
			ofType: NSSQLiteStoreType,
			configurationName: nil,
			at: persistentStoreUrl,
			options: options)
		}
		catch {
		  fatalError("Cannot load persistent store on \(persistentStoreUrl)")
		}
		
		return persistenStoreCoordinator
	}()
	
	private lazy var privateManagedObjectContext: NSManagedObjectContext = {
		let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

		return managedObjectContext
	}()
	
	private(set) lazy var managedObjectContext: NSManagedObjectContext = {
		let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.parent = self.privateManagedObjectContext
		// This merge policy makes the main context read only
		managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		
		return managedObjectContext
	}()
	
	public func backgroundObjectContext() -> NSManagedObjectContext {
		let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		managedObjectContext.parent = self.privateManagedObjectContext
	  
		return managedObjectContext
	}
	
	func saveContext(_ moc: NSManagedObjectContext) {
		moc.performAndWait {
			do {
				if moc.hasChanges {
					try moc.save()
				}
			} catch {
				print("Cannot save changes of background managed object context.")
				print("\(error), \(error.localizedDescription)")
			}
		}
		
		privateManagedObjectContext.perform {
			do {
				if self.privateManagedObjectContext.hasChanges {
					try self.privateManagedObjectContext.save()
				}
			} catch {
				print("Cannot save changes of private managed object context to core data storage.")
				print("\(error), \(error.localizedDescription)")
			}
		}
	}
	
	func clearStorage(entityName: String) {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
	  
		do {
			try managedObjectContext.execute(batchDeleteRequest)
		}
		catch let error as NSError {
			print("Cannot delete local storage for: \(entityName).\nReason: \(error.localizedDescription)")
		}
	}
}

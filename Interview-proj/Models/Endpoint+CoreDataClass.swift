//
//  Endpoint+CoreDataClass.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//
//

import Foundation
import CoreData

@objc(Endpoint)
public class Endpoint: NSManagedObject {

}

extension Endpoint {
	convenience init(name: String, value: String) {
		self.init(context: CoreDataManager.shared.managedObjectContext)
		self.name = name
		self.value = value
	}
}

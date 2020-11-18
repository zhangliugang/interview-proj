//
//  History+CoreDataClass.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//
//

import Foundation
import CoreData

@objc(History)
public class History: NSManagedObject {

}

extension History {
	convenience init(date: Date, success: Bool = true) {
		self.init(context: CoreDataManager.shared.managedObjectContext)
		self.date = date
		self.success = success
	}
}

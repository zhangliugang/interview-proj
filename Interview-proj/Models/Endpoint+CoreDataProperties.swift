//
//  Endpoint+CoreDataProperties.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//
//

import Foundation
import CoreData


extension Endpoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Endpoint> {
        return NSFetchRequest<Endpoint>(entityName: "Endpoint")
    }

    @NSManaged public var name: String?
    @NSManaged public var value: String?
    @NSManaged public var from: History?

}

extension Endpoint : Identifiable {

}

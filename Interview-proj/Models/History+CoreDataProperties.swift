//
//  History+CoreDataProperties.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var success: Bool
    @NSManaged public var endpoint: NSSet?

}

// MARK: Generated accessors for endpoint
extension History {

    @objc(addEndpointObject:)
    @NSManaged public func addToEndpoint(_ value: Endpoint)

    @objc(removeEndpointObject:)
    @NSManaged public func removeFromEndpoint(_ value: Endpoint)

    @objc(addEndpoint:)
    @NSManaged public func addToEndpoint(_ values: NSSet)

    @objc(removeEndpoint:)
    @NSManaged public func removeFromEndpoint(_ values: NSSet)

}

extension History : Identifiable {

}

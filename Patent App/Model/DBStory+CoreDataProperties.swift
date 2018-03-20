//
//  DBStory+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/20/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension DBStory {

    @nonobjc public class func fetchStories() -> NSFetchRequest<DBStory> {
        return NSFetchRequest<DBStory>(entityName: "DBStory")
    }
    
    @NSManaged public var parts: Set<DBStoryPart>
    @NSManaged public var name: String?
    
}

// MARK: Generated accessors for parts
extension DBStory {

    @objc(addPartsObject:)
    @NSManaged public func addToParts(_ value: DBStoryPart)

    @objc(removePartsObject:)
    @NSManaged public func removeFromParts(_ value: DBStoryPart)

    @objc(addParts:)
    @NSManaged public func addToParts(_ values: NSSet)

    @objc(removeParts:)
    @NSManaged public func removeFromParts(_ values: NSSet)

}

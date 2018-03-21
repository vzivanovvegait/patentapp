//
//  DBStory+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/21/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension DBStory {

    @nonobjc public class func fetchStories() -> NSFetchRequest<DBStory> {
        return NSFetchRequest<DBStory>(entityName: "DBStory")
    }

    @NSManaged public var name: String?
    @NSManaged public var parts: NSOrderedSet

}

// MARK: Generated accessors for parts
extension DBStory {

    @objc(insertObject:inPartsAtIndex:)
    @NSManaged public func insertIntoParts(_ value: DBStoryPart, at idx: Int)

    @objc(removeObjectFromPartsAtIndex:)
    @NSManaged public func removeFromParts(at idx: Int)

    @objc(insertParts:atIndexes:)
    @NSManaged public func insertIntoParts(_ values: [DBStoryPart], at indexes: NSIndexSet)

    @objc(removePartsAtIndexes:)
    @NSManaged public func removeFromParts(at indexes: NSIndexSet)

    @objc(replaceObjectInPartsAtIndex:withObject:)
    @NSManaged public func replaceParts(at idx: Int, with value: DBStoryPart)

    @objc(replacePartsAtIndexes:withParts:)
    @NSManaged public func replaceParts(at indexes: NSIndexSet, with values: [DBStoryPart])

    @objc(addPartsObject:)
    @NSManaged public func addToParts(_ value: DBStoryPart)

    @objc(removePartsObject:)
    @NSManaged public func removeFromParts(_ value: DBStoryPart)

    @objc(addParts:)
    @NSManaged public func addToParts(_ values: NSOrderedSet)

    @objc(removeParts:)
    @NSManaged public func removeFromParts(_ values: NSOrderedSet)

}

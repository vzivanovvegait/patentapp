//
//  DBStoryPart+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/20/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension DBStoryPart {

    @nonobjc public class func fetchStoryParts() -> NSFetchRequest<DBStoryPart> {
        return NSFetchRequest<DBStoryPart>(entityName: "DBStoryPart")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var story: DBStory?
    @NSManaged public var words: Set<DBStoryWord>

}

// MARK: Generated accessors for words
extension DBStoryPart {

    @objc(addWordsObject:)
    @NSManaged public func addToWords(_ value: DBStoryWord)

    @objc(removeWordsObject:)
    @NSManaged public func removeFromWords(_ value: DBStoryWord)

    @objc(addWords:)
    @NSManaged public func addToWords(_ values: NSSet)

    @objc(removeWords:)
    @NSManaged public func removeFromWords(_ values: NSSet)

}

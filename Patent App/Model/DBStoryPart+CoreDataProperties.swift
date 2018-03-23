//
//  DBStoryPart+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/21/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension DBStoryPart {

    @nonobjc public class func fetchStoryParts() -> NSFetchRequest<DBStoryPart> {
        return NSFetchRequest<DBStoryPart>(entityName: "DBStoryPart")
    }

    @NSManaged public var imageURL: String
    @NSManaged public var story: DBStory
    @NSManaged public var words: NSOrderedSet

}

// MARK: Generated accessors for words
extension DBStoryPart {

    @objc(insertObject:inWordsAtIndex:)
    @NSManaged public func insertIntoWords(_ value: DBStoryWord, at idx: Int)

    @objc(removeObjectFromWordsAtIndex:)
    @NSManaged public func removeFromWords(at idx: Int)

    @objc(insertWords:atIndexes:)
    @NSManaged public func insertIntoWords(_ values: [DBStoryWord], at indexes: NSIndexSet)

    @objc(removeWordsAtIndexes:)
    @NSManaged public func removeFromWords(at indexes: NSIndexSet)

    @objc(replaceObjectInWordsAtIndex:withObject:)
    @NSManaged public func replaceWords(at idx: Int, with value: DBStoryWord)

    @objc(replaceWordsAtIndexes:withWords:)
    @NSManaged public func replaceWords(at indexes: NSIndexSet, with values: [DBStoryWord])

    @objc(addWordsObject:)
    @NSManaged public func addToWords(_ value: DBStoryWord)

    @objc(removeWordsObject:)
    @NSManaged public func removeFromWords(_ value: DBStoryWord)

    @objc(addWords:)
    @NSManaged public func addToWords(_ values: NSOrderedSet)

    @objc(removeWords:)
    @NSManaged public func removeFromWords(_ values: NSOrderedSet)
    
    func reset() {
        for word in words {
            if let word = word as? DBStoryWord, !word.isSpecial {
                word.isFound = false
                word.wordState = State.oneline.rawValue
            }
        }
    }

}

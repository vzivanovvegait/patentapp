//
//  FlashcardSet+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/23/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension FlashcardSet {

    @nonobjc public class func fetchFlashcardSet() -> NSFetchRequest<FlashcardSet> {
        return NSFetchRequest<FlashcardSet>(entityName: "FlashcardSet")
    }

    @NSManaged public var name: String
    @NSManaged public var flashcards: NSOrderedSet?

}

// MARK: Generated accessors for flashcards
extension FlashcardSet {

    @objc(insertObject:inFlashcardsAtIndex:)
    @NSManaged public func insertIntoFlashcards(_ value: Flashcard, at idx: Int)

    @objc(removeObjectFromFlashcardsAtIndex:)
    @NSManaged public func removeFromFlashcards(at idx: Int)

    @objc(insertFlashcards:atIndexes:)
    @NSManaged public func insertIntoFlashcards(_ values: [Flashcard], at indexes: NSIndexSet)

    @objc(removeFlashcardsAtIndexes:)
    @NSManaged public func removeFromFlashcards(at indexes: NSIndexSet)

    @objc(replaceObjectInFlashcardsAtIndex:withObject:)
    @NSManaged public func replaceFlashcards(at idx: Int, with value: Flashcard)

    @objc(replaceFlashcardsAtIndexes:withFlashcards:)
    @NSManaged public func replaceFlashcards(at indexes: NSIndexSet, with values: [Flashcard])

    @objc(addFlashcardsObject:)
    @NSManaged public func addToFlashcards(_ value: Flashcard)

    @objc(removeFlashcardsObject:)
    @NSManaged public func removeFromFlashcards(_ value: Flashcard)

    @objc(addFlashcards:)
    @NSManaged public func addToFlashcards(_ values: NSOrderedSet)

    @objc(removeFlashcards:)
    @NSManaged public func removeFromFlashcards(_ values: NSOrderedSet)

}

//
//  Flashcard+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/24/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension Flashcard {

    @nonobjc public class func fetchFlashcards() -> NSFetchRequest<Flashcard> {
        return NSFetchRequest<Flashcard>(entityName: "Flashcard")
    }

    @NSManaged public var answer: String
    @NSManaged public var imageData: NSData?
    @NSManaged public var name: String?
    @NSManaged public var question: String?
    @NSManaged public var flashcardSet: FlashcardSet?

}

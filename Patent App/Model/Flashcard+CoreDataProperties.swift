//
//  Flashcard+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 4/2/18.
//
//

import Foundation
import CoreData


extension Flashcard {

    @nonobjc public class func fetchFlashcards() -> NSFetchRequest<Flashcard> {
        return NSFetchRequest<Flashcard>(entityName: "Flashcard")
    }

    @NSManaged public var name: String?
    @NSManaged public var question: String?
    @NSManaged public var answer: String?
    @NSManaged public var isOrdered: Bool

}

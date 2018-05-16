//
//  FlashcardsManager.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/2/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation
import CoreData

class FlashcardsManager {
    
    static let shared = FlashcardsManager()
    
    func getFlashcards() -> [Flashcard] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let flashcardsFetch = Flashcard.fetchFlashcards()
        do {
            let fetchedFlashcards = try context.fetch(flashcardsFetch)
            return fetchedFlashcards
        } catch {
            fatalError("\(error)")
        }
        return []
    }
    
    
    func insertFlashcard(set: FlashcardSet, name: String, question: String? = nil, imageData: NSData? = nil, answer: String) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Flashcard", in: context)
        let newFlashcard = NSManagedObject(entity: entity!, insertInto: context) as! Flashcard
        
        newFlashcard.flashcardSet = set
        newFlashcard.name = name
        newFlashcard.question = question
        newFlashcard.answer = answer
        newFlashcard.imageData = imageData
        
        do {
            try context.save()
            return true
        } catch {
            context.reset()
            return false
        }
    }
    
    func deleteFlashcard(flashcard: Flashcard) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        context.delete(flashcard)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func saveFlashcard() -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
}

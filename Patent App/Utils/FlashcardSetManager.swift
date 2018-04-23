//
//  FlashcardSetManager.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/23/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation
import CoreData

class FlashcardSetManager {
    
    static let shared = FlashcardSetManager()
    
    func getFlashcardSet() -> [FlashcardSet] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let flashcardSetFetch = FlashcardSet.fetchFlashcardSet()
        do {
            let fetchedFlashcardSets = try context.fetch(flashcardSetFetch)
            return fetchedFlashcardSets
        } catch {
            fatalError("\(error)")
        }
        return []
    }
    
    func insertFlashcardSet(name: String) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "FlashcardSet", in: context)
        let newFlashcardSet = NSManagedObject(entity: entity!, insertInto: context) as! FlashcardSet
        
        newFlashcardSet.name = name
        
        do {
            try context.save()
            return true
        } catch {
            context.reset()
            return false
        }
    }
    
    func deleteFlashcardSet(flashcardSet: FlashcardSet) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        context.delete(flashcardSet)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func saveFlashcardSet() -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
}

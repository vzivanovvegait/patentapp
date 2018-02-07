//
//  Note.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/26/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation
import CoreData

class NoteController {
    
    static let shared = NoteController()
    
    func getNotes() -> [Note] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let noteFetch = Note.noteRequest()
        do {
            let fetchedNotes = try context.fetch(noteFetch)
            return fetchedNotes
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return []
    }
    
    func insertNote(word: String, explanation: String) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context) as! Note
        
        newUser.word = word
        newUser.explanation = explanation
        do {
            try context.save()
            return true
        } catch {
            context.reset()
            return false
        }
    }
    
    func deleteNote(note: Note) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        context.delete(note)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
}

//
//  StoryManager.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/20/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation
import CoreData

class StoryManager {
    
    class func populateStories() {
        if let path = Bundle.main.path(forResource: "story", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let storyPart = jsonResult as? [[String: Any]] {
                    let story = StoryManager.createStory(name: "Torn Shoes")
                    for part in storyPart {
                        let storyPart = StoryManager.createStoryPart()
                        if let imageURL = part["image"] as? String {
                            storyPart.imageURL = imageURL
                        }
                        if let words = part["words"] as? [[String: Any]] {
                            StoryManager.getWords(storyPart: storyPart, words: words)
//                            storyPart.words = NSSet(array: StoryManager.getWords(words: words))
                        }
                        story.addToParts(storyPart)
                    }
                }
                StoryManager.save()
            } catch {
            }
        }
    }
    
    private class func getWords(storyPart: DBStoryPart, words: [[String: Any]]) /* -> [DBStoryWord] */{
//        var wordArray = [DBStoryWord]()
        for word in words {
            let singleWord = StoryManager.createStoryWord()
            if let mainString = word["mainString"] as? String {
                singleWord.mainString = mainString
            }
            if let isSpecial = word["isSpecial"] as? Bool {
                singleWord.isSpecial = isSpecial
                if isSpecial {
                    singleWord.isFound = true
                    singleWord.wordState = State.normal.rawValue
                }
            }
            if let hint = word["hint"] as? String {
                singleWord.hint = hint
            }
            if let roots = word["roots"] as? [String] {
                for root in roots {
                    let rootWord = StoryManager.createRootWord()
                    rootWord.word = root
                    singleWord.addToRoots(rootWord)
                }
            }
            storyPart.addToWords(singleWord)
//            wordArray.append(singleWord)
        }
//        return wordArray
    }
    
    private class func save() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
        }
    }
    
    private class func createStory(name: String) -> DBStory {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DBStory", in: context)
        let story = NSManagedObject(entity: entity!, insertInto: context) as! DBStory
        story.name = name
        
        return story
    }
    
    private class func createStoryPart() -> DBStoryPart {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DBStoryPart", in: context)
        let storyPart = NSManagedObject(entity: entity!, insertInto: context) as! DBStoryPart
        
        return storyPart
    }
    
    private class func createStoryWord() -> DBStoryWord {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DBStoryWord", in: context)
        let storyWord = NSManagedObject(entity: entity!, insertInto: context) as! DBStoryWord
        
        return storyWord
    }
    
    private class func createRootWord() -> DBRoot {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DBRoot", in: context)
        let root = NSManagedObject(entity: entity!, insertInto: context) as! DBRoot
        
        return root
    }
}

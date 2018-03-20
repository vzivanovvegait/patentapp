//
//  StoryPartController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/20/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation

class StoryPartController {
    
    class func getStoryParts() -> [DBStoryPart] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let storyPartFetch = DBStoryPart.fetchStoryParts()
        do {
            let fetchedStoryParts = try context.fetch(storyPartFetch)
            return fetchedStoryParts
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return []
    }
}

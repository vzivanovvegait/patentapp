//
//  StoryController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/30/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class StoryController: NSObject {
    
    class func getStory() -> [StoryPart] {
        var storyParts = [StoryPart]()
        if let path = Bundle.main.path(forResource: "story", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let storyPart = jsonResult as? [[String: Any]]{
                    for part in storyPart {
                        var storyPart = StoryPart()
                        if let image = part["image"] as? String {
                            storyPart.image = image
                        }
                        if let words = part["words"] as? [[String: Any]] {
                            storyPart.words = self.getWords(words: words)
                        }
                        storyParts.append(storyPart)
                    }
                }
            } catch {
            }
        }
        return storyParts
    }
    
    class func getWords(words: [[String: Any]]) -> [Word] {
        var wordArray = [Word]()
        for word in words {
            var singleWord = Word()
            if let mainString = word["mainString"] as? String {
                singleWord.mainString = mainString
            }
            if let isSpecial = word["isSpecial"] as? Bool {
                singleWord.isSpecial = isSpecial
            }
            if let hint = word["hint"] as? String {
                singleWord.hint = hint
            }
            if let roots = word["roots"] as? [String] {
                var rootWords = [String]()
                for root in roots {
                    rootWords.append(root)
                }
                singleWord.roots = rootWords
            }
            wordArray.append(singleWord)
        }
        return wordArray
    }

}

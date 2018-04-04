//
//  DataUtils.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/16/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class DataUtils {
    
    class func createString(from array: NSOrderedSet) -> (NSMutableAttributedString, Bool) {
        let attString = NSMutableAttributedString(string: "")
        var rangeCounter = 0
        for index in 0..<array.count {
            if let dbWord = array[index] as? DBStoryWord {
                if index != 0 {
                    if ![".", ",", ":", "?", "!", "?!"].contains(dbWord.mainString) {
                        attString.append(NSMutableAttributedString(string: " "))
                        rangeCounter += 1
                    }
                }
                let word = NSMutableAttributedString(string: dbWord.getString())
                if let state = State(rawValue: dbWord.wordState), [.underlined, .firstLastLetter, .clue].contains(state) {
                    word.addAttribute(NSAttributedStringKey.kern, value: 3, range: NSRange(location: 0, length: dbWord.mainString.count))
                }
                attString.append(word)
                if !dbWord.isSpecial {
                    attString.addAttribute(NSAttributedStringKey.link, value: "\(index)", range: NSRange(location: rangeCounter, length: dbWord.mainString.count))
                }
                
                rangeCounter += dbWord.mainString.count
            }
        }
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: CGFloat((fontSize > 25) ? fontSize : 25)), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        if !Array(array).contains(where: { !($0 as! DBStoryWord).isFound }) {
            return (attString, true)
        }
//        if !array.contains(where: { !$0.isFound }) {
//            return (attString, true)
//        }
        
        return (attString, false)
    }
    
    class func createArrayOfElements(string: String) -> [Element] {
        let wordArray = string.components(separatedBy: " ")
        var words = [Element]()
        
        for word in wordArray {
            if word.contains(",") {
                if let character = word.last, character == "," {
                    let element = Element()
                    element.text = String(word.dropLast())
                    words.append(element)
                    
                    let character = Element()
                    character.text = ","
                    character.isSpecial = true
                    character.isFound = true
                    words.append(character)
                }
            } else if word.contains(".") {
                if let character = word.last, character == "." {
                    let element = Element()
                    element.text = String(word.dropLast())
                    words.append(element)
                    
                    let character = Element()
                    character.isSpecial = true
                    character.isFound = true
                    character.text = "."
                    words.append(character)
                }
            }  else if word.contains(":") {
                if let character = word.last, character == ":" {
                    let element = Element()
                    element.text = String(word.dropLast())
                    words.append(element)
                    
                    let character = Element()
                    character.isSpecial = true
                    character.isFound = true
                    character.text = "."
                    words.append(character)
                }
            }  else if word.contains("!") {
                if let character = word.last, character == "!" {
                    let element = Element()
                    element.text = String(word.dropLast())
                    words.append(element)
                    
                    let character = Element()
                    character.isSpecial = true
                    character.isFound = true
                    character.text = "."
                    words.append(character)
                }
            } else if word.contains("?") {
                if let character = word.last, character == "?" {
                    let element = Element()
                    element.text = String(word.dropLast())
                    words.append(element)
                    
                    let character = Element()
                    character.isSpecial = true
                    character.isFound = true
                    character.text = "."
                    words.append(character)
                }
            } else {
                let element = Element()
                element.text = word
                words.append(element)
            }
        }
        
        return words
    }
    
    class func createFlashcardString(from array: [Element]) -> (NSMutableAttributedString, Bool) {
        let attString = NSMutableAttributedString(string: "")
        var rangeCounter = 0
        for (index, element) in array.enumerated() {
                if index != 0 {
                    if ![".", ",", ":", "?", "!", "?!"].contains(element.text) {
                        attString.append(NSMutableAttributedString(string: " "))
                        rangeCounter += 1
                    }
                }
                let word = NSMutableAttributedString(string: element.getString())
                attString.append(word)
        }
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: CGFloat((fontSize > 25) ? fontSize : 25)), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        if !array.contains(where: { !$0.isFound }) {
            return (attString, true)
        }
        
        return (attString, false)
    }
    
    class func createQuestionString(from string: String) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: string)
        
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: CGFloat((fontSize > 25) ? fontSize : 25)), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        return attString
    }

}

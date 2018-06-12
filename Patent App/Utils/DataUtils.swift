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

        return (attString, false)
    }
    
    class func createElementString(from array: [Element], basicString: String) -> (NSMutableAttributedString, Bool) {
        var string = basicString
        for element in array {
            let s = element.getString()
            string.replaceSubrange(element.range!, with: s)
        }
        let attString = NSMutableAttributedString(string: string)
        for (i,element) in array.enumerated() {
            let nsRange = NSMakeRange(string.distance(from: string.startIndex, to: element.range!.lowerBound), element.text.count)
            if element.elementState == .firstLastLetter {
                attString.addAttribute(NSAttributedStringKey.kern, value: 3, range: nsRange)
            } else {
                attString.addAttribute(NSAttributedStringKey.kern, value: 0, range: nsRange)
            }
            attString.addAttribute(NSAttributedStringKey.link, value: "\(i)", range: nsRange)
        }
        
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: CGFloat((fontSize > 25) ? fontSize : 25)), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))

        if !array.contains(where: { !($0.isFound) }) {
            return (attString, true)
        }
        return (attString, false)
    }
    
    class func createArray(sentence: String) -> [Element] {
        var elements = [Element]()
        let strings = sentence.wordList
        for string in strings {
            let element = Element()
            let ranges = DataUtils.findRanges(for: string, in: sentence)
            if ranges.count > 1 {
               let elementIndex = elements.filter({$0.text.lowercased() == string.lowercased()}).count
                element.range = ranges[elementIndex]
            } else {
                element.range = ranges.first
            }
            
            element.text = string
            elements.append(element)
        }
        return elements
    }
    
    class func findRanges(for word: String, in text: String) -> [Range<String.Index>] {
        do {
            let regex = try NSRegularExpression(pattern: "\\b\(word.lowercased())\\b", options: [])
            
            let fullStringRange = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text.lowercased(), options: [], range: fullStringRange)
            return matches.map {
                Range($0.range, in: text)!
            }
        }
        catch {
            return []
        }
    }
    
    class func createAttributtedString(from string: String) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: string)
        
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: CGFloat((fontSize > 25) ? fontSize : 25)), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        return attString
    }
    
    class func createAnswerString(from string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "'")
        
        let replacedString = String(string.map {
            characterSet.contains($0) ? "_" : $0
        })
        return replacedString
    }

}

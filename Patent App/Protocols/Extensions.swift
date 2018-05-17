//
//  Extensions.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/21/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation

extension String {
    func mapString() -> String {
        return String(self.map {_ in
            return "_"
        })
    }
    
    func mapFirstLastString() -> String {
        let mainStringCount = self.count
        var string = String(repeating: "_", count: mainStringCount)
        if let firstCharacter = self.first, let lastCharacter = self.last {
            string.replace(index: 0, newChar: firstCharacter)
            string.replace(index: mainStringCount - 1, newChar: lastCharacter)
        }
        return string
    }
    
    mutating func replace(index: Int,  newChar: Character) {
        var chars = Array(self)
        chars[index] = newChar
        self = String(chars)
    }
}

extension String {
    var wordList: [String] {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "’")
        return components(separatedBy: characterSet.inverted).filter { !$0.isEmpty }
    }
}

extension CharacterSet {
    func contains(_ character: Character) -> Bool {
        let string = String(character)
        return string.rangeOfCharacter(from: self, options: [], range: string.startIndex..<string.endIndex) != nil
    }
}


extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

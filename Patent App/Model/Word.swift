//
//  Word.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/22/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation

struct Word {
    
    enum State {
        case hidden
        case firstLastLetter
        case normal
    }
    
    var mainString:String
    var isSpecial:Bool
    var isFound:Bool = false
    var wordState:State = .hidden
    
    init(mainString: String, isSpecial: Bool) {
        self.mainString = mainString
        self.isSpecial = isSpecial
        if isSpecial {
            self.isFound = true
            self.wordState = .normal
        }
    }
    
    func getString() -> String {
        if self.isFound {
            return mainString
        } else {
            switch self.wordState {
            case .hidden:
                return mainString.mapString()
            case .firstLastLetter:
                return mainString.mapFirstLastString()
            case .normal:
                return mainString
            }
        }
    }
    
    mutating func check(array: [String]) -> Bool {
        if checkString(in: array) {
            self.isFound = true
            return true
        }
            // TODO: Root words
        else {
            
        }
        return false
    }
    
    mutating func changeState() {
        switch self.wordState {
        case .hidden:
            self.wordState = .firstLastLetter
        case .firstLastLetter:
            self.wordState = .normal
        case .normal:
            break
        }
    }
    
    fileprivate func checkString(in array: [String]) -> Bool {
        return array.contains(where: { $0.uppercased() == mainString.uppercased() }) ? true : false
    }
}

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

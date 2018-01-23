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
    
    mutating func getString(array: [String]) -> String {
        if self.isFound {
            return mainString
        } else {
            if checkString(in: array) {
                self.isFound = true
                return mainString
            } else {
                switch self.wordState {
                case .hidden:
                    return String(mainString.map {_ in
                        return "_"
                    })
                case .firstLastLetter:
                    let mainStringCount = mainString.count
                    var string = String(repeating: "_", count: mainStringCount)
                    string = replace(myString: string, index: 0, newChar: mainString.first!)
                    string = replace(myString: string, index: mainStringCount - 1, newChar: mainString.last!)
                    return string
                case .normal:
                    return mainString
                }
            }
        }
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
    
    func replace(myString: String,  index: Int,  newChar: Character) -> String {
        var chars = Array(myString.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
}

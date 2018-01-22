//
//  Word.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/22/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation

struct Word {
    
    var mainString:String
    var isSpecial:Bool
    var isFound:Bool
    
    mutating func getString(array: [String]) -> String {
        if self.isFound {
            return mainString
        } else {
            if checkString(in: array) {
                self.isFound = true
                return mainString
            } else {
                return String(mainString.map {_ in
                    return "_"
                })
            }
        }
    }
    
    fileprivate func checkString(in array: [String]) -> Bool {
        return array.contains(where: { $0.uppercased() == mainString.uppercased() }) ? true : false
    }
}

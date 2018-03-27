//
//  Word.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/22/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import Foundation

enum State: Int16 {
    case oneline = 0
    case underlined
    case clue
    case firstLastLetter
    case normal
}

//class Word {
//
//    var mainString:String = ""
//
//    var isSpecial:Bool = false {
//        willSet {
//            if newValue {
//                self.isFound = true
//                self.wordState = .normal
//            }
//        }
//    }
//
//    var isFound:Bool = false
//    var roots:[String]?
//    var wordState:State = .oneline
//    var hint:String?
//
//    func getString() -> String {
//        if self.isFound {
//            return mainString
//        } else {
//            switch self.wordState {
//            case .oneline, .underlined:
//                return mainString.mapString()
//            case .firstLastLetter, .clue:
//                if mainString.count > 2 {
//                    return mainString.mapFirstLastString()
//                } else {
//                    return mainString.mapString()
//                }
//            case .normal:
//                return mainString
//            }
//        }
//    }
//
//    func check(array: [String]) -> Bool {
//        if checkString(in: array) {
//            self.isFound = true
//            self.wordState = .normal
//            return true
//        } else if checkRoots(in: array) {
//            self.isFound = true
//            self.wordState = .normal
//            return true
//        } else {
//            return false
//        }
//    }
//
//    func changeState() {
//        switch self.wordState {
//        case .oneline:
//            self.wordState = .underlined
//        case .underlined:
//            self.wordState = .firstLastLetter
//        case .firstLastLetter:
//            self.wordState = .clue
//        case .clue:
//            self.isFound = true
//            self.wordState = .normal
//        case .normal:
//            break
//        }
//    }
//
//    fileprivate func checkString(in array: [String]) -> Bool {
//        return array.contains(where: { $0.uppercased() == mainString.uppercased() }) ? true : false
//    }
//
//    fileprivate func checkRoots(in array: [String]) -> Bool {
//        if let roots = roots {
//            for root in roots {
//                if array.contains(where: { $0.uppercased() == root.uppercased() }) {
//                    return true
//                } else {
//                    continue
//                }
//            }
//        }
//        return false
//    }
//}



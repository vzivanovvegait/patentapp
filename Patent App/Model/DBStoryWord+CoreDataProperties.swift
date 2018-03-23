//
//  DBStoryWord+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/21/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension DBStoryWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBStoryWord> {
        return NSFetchRequest<DBStoryWord>(entityName: "DBStoryWord")
    }

    @NSManaged public var hint: String?
    @NSManaged public var isFound: Bool
    @NSManaged public var isSpecial: Bool
    @NSManaged public var mainString: String
    @NSManaged public var wordState: Int16
    @NSManaged public var roots: NSSet?
    @NSManaged public var storyPart: DBStoryPart?

}

// MARK: Generated accessors for roots
extension DBStoryWord {

    @objc(addRootsObject:)
    @NSManaged public func addToRoots(_ value: DBRoot)

    @objc(removeRootsObject:)
    @NSManaged public func removeFromRoots(_ value: DBRoot)

    @objc(addRoots:)
    @NSManaged public func addToRoots(_ values: NSSet)

    @objc(removeRoots:)
    @NSManaged public func removeFromRoots(_ values: NSSet)
    
    func getString() -> String {
        if self.isFound {
            return mainString
        } else {
            if let state = State(rawValue: self.wordState) {
                switch state {
                case .oneline, .underlined:
                    return mainString.mapString()
                case .firstLastLetter, .clue:
                    if mainString.count > 2 {
                        return mainString.mapFirstLastString()
                    } else {
                        return mainString.mapString()
                    }
                case .normal:
                    return mainString
                }
            } else {
                return mainString
            }
        }
    }
    
    func check(array: [String]) -> Bool {
        if checkString(in: array) {
            self.isFound = true
            self.wordState = State.normal.rawValue
            return true
        } else if checkRoots(in: array) {
            self.isFound = true
            self.wordState = State.normal.rawValue
            return true
        } else {
            return false
        }
    }
    
    func changeState() {
        if let state = State(rawValue: self.wordState) {
            switch state {
            case .oneline:
                self.wordState = State.underlined.rawValue
            case .underlined:
                self.wordState = State.firstLastLetter.rawValue
            case .firstLastLetter:
                self.wordState = State.clue.rawValue
            case .clue:
                self.isFound = true
                self.wordState = State.normal.rawValue
            case .normal:
                break
            }
        }
    }
    
    fileprivate func checkString(in array: [String]) -> Bool {
        return array.contains(where: { $0.uppercased() == mainString.uppercased() }) ? true : false
    }
    
    fileprivate func checkRoots(in array: [String]) -> Bool {
        if let roots = roots {
            for root in roots {
                if let rootNew = root as? DBRoot, array.contains(where: { $0.uppercased() == rootNew.word.uppercased() }) {
                    return true
                } else {
                    continue
                }
            }
        }
        return false
    }

}

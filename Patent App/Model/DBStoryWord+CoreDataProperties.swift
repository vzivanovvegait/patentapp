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

}

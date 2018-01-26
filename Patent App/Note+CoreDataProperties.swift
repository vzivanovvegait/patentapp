//
//  Note+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/26/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func noteRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var word: String?
    @NSManaged public var explanation: String?

}

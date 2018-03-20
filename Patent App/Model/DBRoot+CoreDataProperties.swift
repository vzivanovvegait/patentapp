//
//  DBRoot+CoreDataProperties.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/20/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension DBRoot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBRoot> {
        return NSFetchRequest<DBRoot>(entityName: "DBRoot")
    }

    @NSManaged public var word: String?

}

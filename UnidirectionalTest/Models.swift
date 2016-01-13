//
//  Models.swift
//  UnidirectionalTest
//
//  Created by Sam Ritchie on 30/12/2015.
//  Copyright © 2015 codesplice pty ltd. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    dynamic var id: String = NSUUID().UUIDString
    dynamic var text: String = ""
    dynamic var completed: Bool = false
    
    override class func primaryKey() -> String {
        return "id"
    }
}
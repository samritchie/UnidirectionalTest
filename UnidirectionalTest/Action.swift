//
//  Action.swift
//  UnidirectionalTest
//
//  Created by Sam Ritchie on 30/12/2015.
//  Copyright © 2015 codesplice pty ltd. All rights reserved.
//

import Foundation

enum Action {
    case SetCompletion(id: String, completed: Bool)
    case DeleteItem(id: String)
    case EditItem(id: String, text: String)
    case NewItem(text: String)
}
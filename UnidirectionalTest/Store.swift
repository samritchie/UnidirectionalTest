//
//  Store.swift
//  UnidirectionalTest
//
//  Created by Sam Ritchie on 30/12/2015.
//  Copyright © 2015 codesplice pty ltd. All rights reserved.
//

import Foundation
import RealmSwift

protocol StoreSubscriber: AnyObject {
    func stateDidUpdate(items: [ToDoItem])
}

class Store {
    private let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var subscribers: NSHashTable
    
    init() {
        subscribers = NSHashTable.weakObjectsHashTable()
        notificationToken = realm.addNotificationBlock { notification, realm in
            if notification == .RefreshRequired { realm.refresh() }
            let items = Array(realm.objects(ToDoItem.self))
            for sub in self.subscribers.allObjects {
                (sub as? StoreSubscriber)?.stateDidUpdate(items)
            }
        }
    }
    
    func subscribe(sub: StoreSubscriber) {
        subscribers.addObject(sub)
        sub.stateDidUpdate(Array(realm.objects(ToDoItem.self)))
    }
    
    func dispatch(action: Action) {
        try! realm.write {
            switch action {
            case let .SetCompletion(id, completed):
                setCompletion(id, completed: completed)
            case let .DeleteItem(id):
                deleteItem(id)
            case let .EditItem(id, text):
                editItem(id, text: text)
            case let .NewItem(text):
                newItem(text)
            }
        }
    }
    
    private func setCompletion(id: String, completed: Bool) {
        if let item = realm.objectForPrimaryKey(ToDoItem.self, key: id) {
            item.completed = completed
        }
    }
    
    private func deleteItem(id: String) {
        if let item = realm.objectForPrimaryKey(ToDoItem.self, key: id) {
            realm.delete(item)
        }
    }
    
    private func editItem(id: String, text: String) {
        if let item = realm.objectForPrimaryKey(ToDoItem.self, key: id) {
            item.text = text
        }
    }
    
    private func newItem(text: String) {
        let item = ToDoItem()
        item.text = text
        realm.add(item)
    }
}

let store = Store()

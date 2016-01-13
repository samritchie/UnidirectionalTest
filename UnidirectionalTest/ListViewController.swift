//
//  ViewController.swift
//  UnidirectionalTest
//
//  Created by Sam Ritchie on 30/12/2015.
//  Copyright © 2015 codesplice pty ltd. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, StoreSubscriber {
    @IBOutlet var newItemTextField: UITextField!

    var items: [ToDoItem] = []
    var selectedItemRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self)
    }

    func stateDidUpdate(items: [ToDoItem]) {
        self.items = items
        self.selectedItemRow = nil
        tableView.tableHeaderView?.frame = CGRectZero
        tableView.tableHeaderView?.hidden = true
        tableView.tableHeaderView = tableView.tableHeaderView
        newItemTextField.text = nil
        tableView.reloadData()
    }
    
    @IBAction func newItem(sender: AnyObject) {
        tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: 44))
        tableView.tableHeaderView?.hidden = false
        tableView.tableHeaderView = tableView.tableHeaderView
    }
    
    @IBAction func saveNewItem(sender: AnyObject) {
        store.dispatch(Action.NewItem(text: newItemTextField.text!))
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let todoItem = items[indexPath.row]
        if selectedItemRow == indexPath.row {
            let cell = tableView.dequeueReusableCellWithIdentifier("EditItem", forIndexPath: indexPath) as! EditItemCell
            cell.itemTextField.text = todoItem.text
            cell.id = todoItem.id
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Item", forIndexPath: indexPath)
            cell.textLabel?.text = todoItem.text
            if todoItem.completed {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            return cell
        }
    }
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { _, i in
            let prevSelected = self.selectedItemRow
            self.selectedItemRow = i.row
            tableView.reloadRowsAtIndexPaths([i], withRowAnimation: .None)
            if let prevSelected = prevSelected {
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: prevSelected, inSection: 0)], withRowAnimation: .None)
            }
        }
        editAction.backgroundColor = UIColor.darkGrayColor()
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { _, i in
            let todoItem = self.items[i.row]
            store.dispatch(Action.DeleteItem(id: todoItem.id))
        }

        return [deleteAction, editAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todoItem = self.items[indexPath.row]
        store.dispatch(Action.SetCompletion(id: todoItem.id, completed: !todoItem.completed))
    }
}

class EditItemCell: UITableViewCell {
    var id: String!
    @IBOutlet var itemTextField: UITextField!
    
    @IBAction func saveItem(sender: AnyObject) {
        store.dispatch(.EditItem(id: id, text: itemTextField.text!))
    }
}
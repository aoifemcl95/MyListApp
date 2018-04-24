//
//  ViewController.swift
//  MyListApp
//
//  Created by Aoife McLaughlin on 05/04/2018.
//  Copyright © 2018 Aoife McLaughlin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems = [ToDoItem]()
    
    let impact = UIImpactFeedbackGenerator()
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To Do List"
        self.tableView.isEditing = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAddItemButton(_:)))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = .none
        tableView.rowHeight = 50.0
        tableView.backgroundColor = UIColor.white
        if toDoItems.count > 0 {
            return
        }
        
        toDoItems.append(ToDoItem(text:""))

        //setup notification when app about to close so can store data to persistence
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        do {
            self.toDoItems = try [ToDoItem].readFromPersistence()
        }
        catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
            {
                NSLog("No persistence file found, maybe not an error...")
            }
            else
            {
                let alert = UIAlertController(title: "Error", message: "Could not load the to-do items", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                 NSLog("Error loading from persistence: \(error)")
            }
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
//        cell.textLabel?.backgroundColor = UIColor.clear
        let item = toDoItems[indexPath.row]
//        cell.textLabel?.text = item.text
        cell.selectionStyle = .none
        cell.delegate = self
        cell.toDoItem = item
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.toDoItems[sourceIndexPath.row]
        toDoItems.remove(at: sourceIndexPath.row)
        toDoItems.insert(movedObject, at: destinationIndexPath.row)
        NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) \(toDoItems)")
        // To check for correctness enable: self.tableView.reloadData()
    }
    
    func toDoItemsDeleted(todoItem: ToDoItem) {
        let index = (toDoItems as NSArray).index(of: todoItem)
        if index == NSNotFound { return }
        
        toDoItems.remove(at: index)
        
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPathForRow as IndexPath], with: .fade)
        impact.impactOccurred()
        
        tableView.endUpdates()
    
    }
    
    @objc func didTapAddItemButton(_ sender: UIBarButtonItem)
    {
        let alert = UIAlertController(title: "New to-do item", message: "Insert the title of the new to-do item:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text
            {
                self.addNewItemToDoItem(title: title)
            }
            }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func addNewItemToDoItem(title:String)
    {
        let newIndex = toDoItems.count
        toDoItems.append(ToDoItem(text: title))
        
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
    
    // Table view delegate
    
    func colorForIndex(index:Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(displayP3Red: 1.0, green: val, blue: 0.0, alpha: 1.0)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex(index: indexPath.row)
        
    }
    
    
func applicationDidEnterBackground(_ notification: NSNotification) 
    {
        do
        {
            try toDoItems.writeToPersistance()
        }
        catch let error
        {
            NSLog("Error writing to persistence: \(error)")
        }
    }
}


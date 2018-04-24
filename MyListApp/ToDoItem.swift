//
//  ToDoItem.swift
//  MyListApp
//
//  Created by Aoife McLaughlin on 05/04/2018.
//  Copyright © 2018 Aoife McLaughlin. All rights reserved.
//

import UIKit

class ToDoItem: NSObject, NSCoding {
    var text: String
    var completed: Bool
    
    init(text: String) {
        self.text = text
        self.completed = false
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.completed, forKey: "completed")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let text = aDecoder.decodeObject(forKey: "text") as? String
        {
            self.text = text
        }
        else {
            return nil //tells user decoding failed, won't show in app
        }
        
        if aDecoder.containsValue(forKey: "completed")
        {
            self.completed = aDecoder.decodeBool(forKey: "completed")
        }
        else {
            return nil
        }
    }
}
    
    extension Collection where Iterator.Element == ToDoItem
    {
        private static func persistancePath() -> URL?
        {
            let url = try? FileManager.default.url(for: .applicationSupportDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
            
            return url?.appendingPathComponent("todoitem.bin")
        }
        
        func writeToPersistance() throws
        {
            if let url = Self.persistancePath(), let array = self as? NSArray
            {
                let data = NSKeyedArchiver.archivedData(withRootObject: array)
                try data.write(to: url)
            }
            else
            {
                throw NSError(domain: "com.example.MyToDo", code: 10, userInfo: nil)
            }
        }
        static func readFromPersistence() throws -> [ToDoItem]
        {
            if let url = persistancePath(), let data = (try Data(contentsOf: url) as Data?)
            {
                if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ToDoItem]
                {
                    return array
                }
                else
                {
                    throw NSError(domain: "com.example.MyToDo", code: 11, userInfo: nil)
                }
            }
            else
            {
                throw NSError(domain: "com.example.MyToDo", code: 12, userInfo: nil)
            }
        }
    }


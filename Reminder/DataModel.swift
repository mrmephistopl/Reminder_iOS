//
//  DataModel.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 19.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import Foundation

class DataModel {
    var toDoItems = [ToDoItem]()
    
    
    init() {
     //   toDoItems = [ToDoItem]()
        loadToDoItems()
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Reminder.plist")
    }
    
    func saveToDoItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(toDoItems, forKey: "ToDoItems")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
        
    }
    
    func loadToDoItems() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            toDoItems = unarchiver.decodeObject(forKey: "ToDoItems") as! [ToDoItem]
            unarchiver.finishDecoding()
        }
    }
   
}

//
//  ToDoItem.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 14.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class ToDoItem: NSObject, NSCoding, CLLocationManagerDelegate {
    var title = ""
    var desc = ""
    var checked = false
    var date = Date()
    var shouldRemind = false
    var toDoItemID: Int
    var locValue: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
   
    func toogleChecked() {
        checked = !checked
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "Title")
        aCoder.encode(checked, forKey: "Checked")
        aCoder.encode(desc, forKey: "Description")
        aCoder.encode(toDoItemID, forKey: "ToDoItemID")
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "Title") as! String
        desc = aDecoder.decodeObject(forKey: "Description") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        toDoItemID = aDecoder.decodeInteger(forKey: "ToDoItemID")
    }
    
    override init () {
        toDoItemID = TableViewController.nextToDoItemID()
        super.init()
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && date > Date() {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = desc
            content.sound = UNNotificationSound.default()
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(toDoItemID)", content: content , trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(toDoItemID)"])
    }
    
    deinit {
        removeNotification()
    }
}

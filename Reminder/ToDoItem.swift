//
//  ToDoItem.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 14.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import Foundation

class ToDoItem {
    var title = ""
    var description = ""
    var checked = false
    
    func toogleChecked() {
        checked = !checked
    }
}

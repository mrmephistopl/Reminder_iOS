//
//  ReminderSideMenu.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 22.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import Foundation

class ReminderSideMenu: UIViewController {
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}

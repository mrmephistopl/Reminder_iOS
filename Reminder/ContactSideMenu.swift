//
//  ContactSideMenu.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 22.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import Foundation

class ContactSideMenu: UIViewController {
    
    override func viewDidLoad() {
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        backgroundImage()
    }
    
    func backgroundImage() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "tlo@1x.png")?.drawAsPattern(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }

}

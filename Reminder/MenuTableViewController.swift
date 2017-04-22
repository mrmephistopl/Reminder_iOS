//
//  MenuTableViewController.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 22.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    @IBOutlet weak var reminderCell: UITableViewCell!
    @IBOutlet weak var contactCell: UITableViewCell!
    @IBOutlet weak var authorCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 3
    }
    
    func backgroundImage() {
        let bgReminderView = UIView()
        let bgContactView = UIView()
        let bgAuthorView = UIView()
        
        reminderCell.backgroundColor = UIColor.clear
        bgReminderView.backgroundColor = UIColor.red
        reminderCell.selectedBackgroundView = bgReminderView
        
        contactCell.backgroundColor = UIColor.clear
        bgContactView.backgroundColor = UIColor.red
        contactCell.selectedBackgroundView = bgContactView
        
        authorCell.backgroundColor = UIColor.clear
        bgAuthorView.backgroundColor = UIColor.red
        authorCell.selectedBackgroundView = bgAuthorView
        
        tableView.separatorStyle = .none
        tableView.backgroundView = UIImageView(image: UIImage(named: "TloMenu@1x.png"))
    }

}

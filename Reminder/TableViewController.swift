//
//  TableViewController.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 14.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, AddViewControllerDelegate {
  
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var toDoItems: [ToDoItem]
    
    
   required init?(coder aDecoder: NSCoder) {
        toDoItems = [ToDoItem]()
        
        let firstItem = ToDoItem()
        firstItem.title = "Zakupy"
        firstItem.desc = "Chleb, woda, masło"
        firstItem.checked = false
        toDoItems.append(firstItem)
        
        super.init(coder: aDecoder)
        loadToDoItems()
        registerDefaults()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        leftSideMenu()
        customizeNavigationBar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoItems.count
        
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem", for: indexPath)
        let item = toDoItems[indexPath.row]
    
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let item = toDoItems[indexPath.row]
            item.toogleChecked()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        saveToDoItems()
    }

    func configureCheckmark(for cell: UITableViewCell, with item: ToDoItem) {
        let label = cell.viewWithTag(1002) as! UILabel
        
        if item.checked{
            label.text = "☑︎"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ToDoItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        let labelDesc = cell.viewWithTag(1001) as! UILabel
        label.text = item.title
        labelDesc.text = item.desc
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        toDoItems.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        saveToDoItems()
    }
    
    func addViewControllerDidCancel(_ controller: AddViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addViewController(_ controller: AddViewController, didFinishAdding item: ToDoItem) {
        let newRowIndex = toDoItems.count
        toDoItems.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        dismiss(animated: true, completion: nil)
        saveToDoItems()
    }
    
    func addViewController(_ controller: AddViewController, didFinishEditing item: ToDoItem) {
        if let index = toDoItems.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        dismiss(animated: true, completion: nil)
        saveToDoItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add" {
            let navigationController = segue.destination
                as! UINavigationController
            let controller = navigationController.topViewController as! AddViewController
            controller.delegate = self
        } else if segue.identifier == "Edit" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                controller.itemToEdit = toDoItems[indexPath.row]
            }
        }
    }
    
    func registerDefaults() {
    let dictionary: [String: Any] = [ "ToDoItemID": 0 ]
    UserDefaults.standard.register(defaults: dictionary)
    }
    
    class func nextToDoItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let toDoItemID = userDefaults.integer(forKey: "ToDoItemID")
        userDefaults.set(toDoItemID+1, forKey: "ToDoItemID")
        userDefaults.synchronize()
        return toDoItemID
    }
    
    
    //Przechowywanie w pamięci
 
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
    
    //Slide out menu
    
    func leftSideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 175
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func customizeNavigationBar() {
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 255/255, green: 87/255, blue: 35/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    
}

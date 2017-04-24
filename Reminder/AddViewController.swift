//
//  AddViewController.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 14.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import UIKit
import Dispatch
import UserNotifications

protocol AddViewControllerDelegate: class {
    func addViewControllerDidCancel(_ controller: AddViewController)
    func addViewController(_ controller: AddViewController, didFinishAdding item: ToDoItem)
    func addViewController(_ controller: AddViewController, didFinishEditing item: ToDoItem)
}

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIView!
    
    
    var itemToEdit: ToDoItem?
    weak var delegate: AddViewControllerDelegate?
    var date = Date()
    let delay = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        backgroundImage()
        
        if let item = itemToEdit {
            title = "Edit"
            titleTextField.text = item.title
            descriptionTextField.text = item.desc
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = item.shouldRemind
            date = item.date
            datePicker.setDate(date, animated: false)
            dateLabel.textColor = UIColor.red
        }
        updateDateLabel()
       // doneBarButton.isEnabled = false
        titleTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
        
        pickerView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        if let toDoItem = itemToEdit {
            toDoItem.title = titleTextField.text!
            if let description = descriptionTextField.text {
                toDoItem.desc = description
            }
            
            toDoItem.shouldRemind = shouldRemindSwitch.isOn
            toDoItem.date = date
            toDoItem.scheduleNotification()
            
            hudView.text = "Uptaded"
            
            
            delegate?.addViewController(self, didFinishEditing: toDoItem)
        } else {
        
        let toDoItem = ToDoItem()
        toDoItem.title = titleTextField.text!
        if let description = descriptionTextField.text {
           toDoItem.desc = description
        }
            
        toDoItem.checked = false
        toDoItem.shouldRemind = shouldRemindSwitch.isOn
        toDoItem.date = date
        toDoItem.scheduleNotification()
            
        hudView.text = "Added"
            
        delegate?.addViewController(self, didFinishAdding: toDoItem)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute:
            { self.dismiss(animated: true, completion: nil) })
    }
    
    @IBAction func cancel() {
        delegate?.addViewControllerDidCancel(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //titleTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /* func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }*/
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let title = titleTextField.text, !title.isEmpty
            else {
                doneBarButton.isEnabled = false
                return
        }
        doneBarButton.isEnabled = true
    }
    
    func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
    }
    
    @IBAction func dataChange(_ dataPicker: UIDatePicker) {
        date = dataPicker.date
        updateDateLabel()
    }
    
    @IBAction func shuldRemind(_ switchControl: UISwitch) {
        titleTextField.resignFirstResponder()
        
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
            }
            
        }
    }
    
    
    @IBAction func showUpPickerView(_ sender: Any) {
        self.view.addSubview(pickerView)
        pickerView.center = self.view.center
        
        pickerView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        pickerView.alpha = 1
    }
    
    @IBAction func dismissPickerView(_ sender: Any) {
        self.pickerView.removeFromSuperview()
    }
    
    
    

    
    func customizeNavigationBar() {
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 255/255, green: 87/255, blue: 35/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    func backgroundImage() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "tlo.png")?.drawAsPattern(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func delayedAction() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Updated"
    }
    
 
    
    /*
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
       
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    } */


    
}

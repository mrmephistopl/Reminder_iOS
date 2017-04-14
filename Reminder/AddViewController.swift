//
//  AddViewController.swift
//  Reminder
//
//  Created by Mateusz Potasnik on 14.04.2017.
//  Copyright © 2017 Mateusz Potasnik. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate: class {
    func addViewControllerDidCancel(_ controller: AddViewController)
    func addViewController(_ controller: AddViewController, didFinishAdding item: ToDoItem)
}

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    weak var delegate: AddViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneBarButton.isEnabled = false
        titleTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        let toDoItem = ToDoItem()
        toDoItem.title = titleTextField.text!
        if let description = descriptionTextField.text {
           toDoItem.description = description
        }
        toDoItem.checked = false
        
        delegate?.addViewController(self, didFinishAdding: toDoItem)
    }
    
    @IBAction func cancel() {
        delegate?.addViewControllerDidCancel(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
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
    
    /*
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
       
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    } */


    
}

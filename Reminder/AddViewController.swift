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
import MapKit
import CoreLocation

protocol AddViewControllerDelegate: class {
    func addViewControllerDidCancel(_ controller: AddViewController)
    func addViewController(_ controller: AddViewController, didFinishAdding item: ToDoItem)
    func addViewController(_ controller: AddViewController, didFinishEditing item: ToDoItem)
}


class AddViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIView!
 
    @IBOutlet weak var map: MKMapView!

    let locationManager = CLLocationManager()

    var itemToEdit: ToDoItem?
    weak var delegate: AddViewControllerDelegate?
    var date = Date()
    let delay = 0.5

    var locationCoordinate = CLLocationCoordinate2D()
    //////////////
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startManagerLocation()
        customizeNavigationBar()
        backgroundImage()
       // searchTable()
        
        if let item = itemToEdit {
            title = "Edit"
            titleTextField.text = item.title
            descriptionTextField.text = item.desc
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = item.shouldRemind
            date = item.date
            datePicker.setDate(date, animated: false)
            dateLabel.textColor = UIColor.red
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(item.locValue.latitude, item.locValue.longitude)
            annotation.title = titleTextField.text
            map.addAnnotation(annotation)
        }
        updateDateLabel()
       // doneBarButton.isEnabled = false
        titleTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
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
            toDoItem.locValue = locationCoordinate
            hudView.text = "Uptaded"
            toDoItem.locValue = locationCoordinate
            
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
        toDoItem.locValue = locationCoordinate
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
    
    
    ///////////////////////////////////MAPY////////////////////////

    func startManagerLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    @IBAction func showBarButton(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.map.annotations.count != 0{
            annotation = self.map.annotations[0]
            self.map.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
    
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.map.centerCoordinate = self.pointAnnotation.coordinate
            self.map.addAnnotation(self.pinAnnotationView.annotation!)
            self.locationCoordinate = CLLocationCoordinate2DMake(localSearchResponse!.boundingRegion.center.latitude, localSearchResponse!.boundingRegion.center.longitude)
        }
    }
  
    

}



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

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class AddViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIView!
 
    @IBOutlet weak var map: MKMapView!

    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil


    var itemToEdit: ToDoItem?
    weak var delegate: AddViewControllerDelegate?
    var date = Date()
    let delay = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startManagerLocation()
        customizeNavigationBar()
        backgroundImage()
        locationSearch()
    
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
        //    toDoItem.locValue = locationCoordinate
            hudView.text = "Uptaded"
       //     if locationCoordinate.latitude != 0 {
        //        toDoItem.locValue = self.locationCoordinate }
            
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
    //    if locationCoordinate.latitude != 0 {
    //        toDoItem.locValue = self.locationCoordinate }
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
    
    func searchController() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.handleMapSearchDelegate? = self as HandleMapSearch
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = map
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func locationSearch() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = map
    }

}

extension AddViewController : CLLocationManagerDelegate {
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
        print("error:: (error)")
    }
}

extension AddViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        map.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        map.setRegion(region, animated: true)
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

extension AddViewController : MKMapViewDelegate {
    func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = map.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(AddViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}




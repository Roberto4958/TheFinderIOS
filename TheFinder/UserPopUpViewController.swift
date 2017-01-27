//
//  PopUpViewController.swift
//  TheFinder
//
//  Created by roberto on 1/20/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import UIKit
import CoreLocation

class UserPopUpViewController: UIViewController, CLLocationManagerDelegate {
    //@IBOutlet weak var loadBar: UIActivityIndicatorView!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!

    @IBOutlet weak var placeLable: UITextField!
    let locationManager = CLLocationManager()
    let url = "http://thefinder-1.s4c2qwepti.us-west-2.elasticbeanstalk.com/webresources/addNewLocation/"
    var user: User!
    var alreadyGotLocation = false
    var brain = PopUpBrain()
    
    /*
     *@desc: hides spinner, makes background transperant, sets up tap gesture escape keyboard, and sets up location manager
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBar.stopAnimating()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestWhenInUseAuthorization()
        
        //escape keyboard when tap anywhere
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*
     *@desc: escapes from pop up
     */
    @IBAction func CancleButtonClicked(_ sender: CancelButton) {
        self.view.removeFromSuperview()
    }
    
    /*
     *@desc: checks if its safe to make a addLocation API call, and then starts getting users location
     */
    @IBAction func SaveButtonClicked(_ sender: SaveButton) {
        if !Reachability().isConnectedToNetwork(){ //check if user is connected to the internet
            makeAlert(complaint: "Please connect to the internet")
            return
        }
        //checks if users input is safe to put in the addLocation API call
        if let notSafeString = brain.saveButtionClicked(place: placeLable.text!){
            makeAlert(complaint: notSafeString)
        }
        else{ self.locationManager.requestLocation()}
    }

    /*
     *@desc: checks if it already has a location, and if not saves the location
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager.stopUpdatingLocation()
        if alreadyGotLocation {return}
        else {alreadyGotLocation = true}
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(CLPlacemark, error)-> Void
        in
            if error !=  nil{
                print("there was a error: ")
            }
            else{
                let pm = CLPlacemark![0] as CLPlacemark
                self.displayLocationInfo(placeMark: pm)
            }
        })
    }
    
    /*
     *@param: placeMark - users current location
     *@desc: makes addLocation API call
     */
    func displayLocationInfo(placeMark: CLPlacemark){
        let lat = placeMark.location?.coordinate.latitude
        let long = placeMark.location?.coordinate.longitude
        let encodedPlace = placeLable.text!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        makeAddLocationRequest(URLInString: url + encodedPlace!  + "/" + String(describing: lat!) + "/" + String(describing: long!) + "/" + String(user!.ID) + "/" + user!.authToken)
    }
    
    /*
     *@desc: warns user there was a error, and hids the spinner
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        makeAlert(complaint: "Could not get your location")
        loadBar.stopAnimating()
    }
    
    /*
     *@param: complaint - String of what the program wants the user know user
     *@desc: Puts the String parameter on a pop up and shows it to the user
     */
    func makeAlert(complaint: String){
        
        if !loadBar.isHidden {loadBar.stopAnimating()}
        let alert = UIAlertController(title: "Alert", message: complaint, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        loadBar.stopAnimating()
    }
    
    /*
     *@param: data - API response from the add location API call
     *@desc: checks if the data came in ok, and deletes location from array
     */
    func doneMakingRequest(data: Data){
        do{
            let jsonUser = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            if let status = jsonUser["status"] as? String{
                if status == "OK"{//deletes location from arraylist and reloads data
                    makeAlert(complaint: "Success!")
                    self.view.removeFromSuperview()
                }
                else if status == "TOKENCLEARED"{ //logs user out
                    let signInView = self.storyboard!.instantiateViewController(withIdentifier: "StartOfApp")
                    let appDelagate = UIApplication.shared.delegate as! AppDelegate
                    appDelagate.window!.rootViewController = signInView
                }
            }
            else{makeAlert(complaint: "Server Error") }
            
        }
        catch{
            makeAlert(complaint: "Errror: please report this")
        }
    }
    
    
    //------------------API call---------------//
    
    /*
     *@param: URLInString - String containing the url to make a add Location request
     *@desc: Makes a add location API call
     */
    func makeAddLocationRequest(URLInString: String)
    {
        
        print(URLInString)
        
        let url:NSURL = NSURL(string: URLInString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "PUT"
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                    self.makeAlert(complaint: "Error: please report this error")
                    return
                }
                
                if let user = data{ self.doneMakingRequest(data: user)}
                else {self.makeAlert(complaint: "Error: please report this error")}
            }
        }
        loadBar.startAnimating()
        task.resume()
    }

}

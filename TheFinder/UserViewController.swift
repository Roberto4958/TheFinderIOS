//
//  UserViewController.swift
//  TheFinder
//
//  Created by roberto on 10/5/16.
//  Copyright © 2016 TheFinder. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var loadBar: UIActivityIndicatorView!
    var USER: User!
    var lastLocation: Location? = nil
    private var UIButtonclicked = false
    let url = "http://thefinder-1.s4c2qwepti.us-west-2.elasticbeanstalk.com/webresources/"


    /*
     *@desc: Makes findlocation API call if user is connected to the internet
     */
    @IBAction func getLastLocationButtonClicked(_ sender: MainButton) {
        if !Reachability().isConnectedToNetwork(){ //check if user is connected to the internet
            makeAlert(complaint: "Please connect to the internet")
            return
        }
        makeGetLocationRequest(URLInString: url + "findLocation/" + String(USER!.ID) + "/" + USER!.authToken)
    }
    
    /*
     *@desc: Passes the User Object to the PopUpViewController then shows the PopUpViewController
     */
    @IBAction func addLocationbuttonClicked(_ sender: UIButton) {
        let popUp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userPopUp") as! UserPopUpViewController
        popUp.user = USER!
        self.addChildViewController(popUp)
        popUp.view.frame = self.view.frame
        self.view.addSubview(popUp.view)
        self.didMove(toParentViewController: self)
    }
    
    /*
     *@desc: If user is connected to internet makes a history API call
     */
    @IBAction func historyButtonClicked(_ sender: UIButton) {
        if !Reachability().isConnectedToNetwork(){ //check if user is connected to the internet
            makeAlert(complaint: "Please connect to the internet")
            return
        }
        loadBar.startAnimating()
        makeHistoryRequest(URLInString: url + "history/" + String(USER.ID) + "/" + USER.authToken)
    }
    
    /*
     *@desc: hids spin bar, and hides back button
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBar.stopAnimating()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    /*
     *@desc: Hides spinner
     */
    override func viewDidDisappear(_ animated: Bool) {
        loadBar.stopAnimating()
    }
    
    /*
     *@desc: Opens map and passes in the location
     */
    func OpenMap(location: Location){
        makeAlert(complaint: "successfully open map")
    }
    
    /*
     *@param: data - API response from the getLocation API call
     *@desc: Checks if the response came in ok and passes the information to open map with the users last location
     */
    func doneGetLocationRequest(data: Data){
        do{//converts the data into redable form
            let jsonLocation = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            //gets the status of the response
            if let status = jsonLocation["status"] as? String{
               
                if status == "OK"{ // if status = OK then gets response and convert it to a Location Object
                    if let locationInfo = jsonLocation["locationInfo"] as? NSDictionary{
                        let lat = locationInfo["latitude"]
                        let long = locationInfo["longtitude"]
                        let locationID = locationInfo["locationID"]
                        let place = locationInfo["place"]
                        let location = Location(lat: lat as! Double, longt: long as! Double, lID: locationID as! Int, p: place as! String)
                        OpenMap(location: location)
                    }
                    else{
                        makeAlert(complaint: "you have not have added any Location")
                    }
                }
                //if status = TOKENCLEARED then the user is loged out
                else if status == "TOKENCLEARED"{
                    let signInView = self.storyboard!.instantiateViewController(withIdentifier: "StartOfApp")
                    let appDelagate = UIApplication.shared.delegate as! AppDelegate
                    appDelagate.window!.rootViewController = signInView
                }
                else{makeAlert(complaint: "Server Error")}
            }
            else{makeAlert(complaint: "error: please report this error")}
        }
        catch{
            makeAlert(complaint: "error: please report this error")
        }    
    }
    
    /*
     *@param: data - API response from the history API call
     *@desc: checks if the data came in ok, and passes it to the TableView controll
     */
    func doneMakingHistoryRequest(data: Data){
        do{//converts the data into redable form
            let jsonUser = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            //gets the status of the response
            if let status = jsonUser["status"] as? String{
                
                //converts data to a arrayList of Location Objects and passs it to the TableView
                if status == "OK"{
                    if let userInfo = jsonUser["UserLocations"] as? [NSDictionary]{
                        
                        if userInfo.isEmpty{
                            makeAlert(complaint: "You do not have any locations stored")
                            return
                        }
                        var location = [Location] ()
                        for i in 0...(userInfo.count - 1){
                            let dictinary = userInfo[i]
                            let lat = dictinary["latitude"]
                            let long = dictinary["longtitude"]
                            let locationID = dictinary["locationID"]
                            let place = dictinary["place"]
                            let l = Location(lat: lat as! Double, longt: long as! Double, lID: locationID as!Int, p: place as! String)
                            location.append(l)
                        }
                        
                        performSegue(withIdentifier: "gotoHistory", sender: location)
                    }
                    else{ makeAlert(complaint: "Error: Please report this error")}
                }
                else if status == "TOKENCLEARED"{
                    
                }
                else { makeAlert(complaint: "server error")}
            }
        }
        catch{
            makeAlert(complaint: "Error: Please report this error")
        }
    }
    
    /*
     *@param: complaint - String of what the program wants the user know user
     *@desc: Puts the String parameter on a pop up and shows it to the user
     */
    func makeAlert(complaint: String){
        if loadBar.isAnimating {loadBar.stopAnimating()}
        let alert = UIAlertController(title: "Alert", message: complaint, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     *@param: sender - ArrayList of Location, of all the users location
     *@desc: Passes sender to the HistoryTableViewController
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "gotoHistory"{
            if let destination = segue.destination as? HistoryTableViewController{
                destination.locations = sender as? [Location]
                destination.USER = USER
            }
        }
    }
    
    /*
     * @desc: logsout the user both in the database and the UI
     */
    @IBAction func logOutButtonClicked(_ sender: UIBarButtonItem) {
        makeLogOutRequest(URLInString: url + "logOut/" + String(USER!.ID) + "/" + USER!.authToken)
        let signInView = self.storyboard!.instantiateViewController(withIdentifier: "StartOfApp")
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        appDelagate.window!.rootViewController = signInView
        
    }
    
    //------------------API calls---------------//
    
    /*
     *@param: URLInString - String containing the url to make a history request
     *@desc: Makes a history API call
     */
    func makeHistoryRequest(URLInString: String)
    {
        let url:NSURL = NSURL(string: URLInString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                    self.makeAlert(complaint: "Error: please report this error")
                    return
                }
                
                if let user = data{ self.doneMakingHistoryRequest(data: user)}
                else {self.makeAlert(complaint: "Error: please report this error")}
            }
        }
        loadBar.startAnimating()
        task.resume()
    }
    
    /*
     *@param: URLInString - String containing the url to make a log out request
     *@desc: Makes a log out API call
     */
    func makeLogOutRequest(URLInString: String)
    {
        let url:NSURL = NSURL(string: URLInString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                    self.makeAlert(complaint: "Error: please report this error")
                    return
                }
            }
        }
        task.resume()
    }
    
    /*
     *@param: URLInString - String containing the url to make a get location request
     *@desc: Makes a get location API call
     */
    func makeGetLocationRequest(URLInString: String)
    {
        print(URLInString)
        let url:NSURL = NSURL(string: URLInString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                    self.makeAlert(complaint: "Error: please report this error")
                    return
                }
                if let location = data{ self.doneGetLocationRequest(data: location)}
                else {self.makeAlert(complaint: "Error: please report this error")}
            }
        }
        loadBar.startAnimating()
        task.resume()
    }
}

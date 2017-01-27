//
//  HistoryTableViewController.swift
//  TheFinder
//
//  Created by roberto on 1/18/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import UIKit
import MapKit

class HistoryTableViewController: UITableViewController {

    
    var locations: [Location]? = nil
    let url: String = "http://thefinder-1.s4c2qwepti.us-west-2.elasticbeanstalk.com/webresources/"
    var USER: User? = nil
    var waitingFordata: Int? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return locations!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /*
     *@desc: inserts users data into each cell
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = locations![indexPath.section]
        let dequeue = tableView.dequeueReusableCell(withIdentifier: "historyRow", for: indexPath)
        
        if let cell = dequeue as? HistoryTableViewCell {
            cell.location = data

            //if waitingFordata is not nil then user is currently deleting a location
            if let i  = waitingFordata {
                if i == indexPath.section{
                    cell.loadBar!.startAnimating()
                    waitingFordata = nil
                }
            }
            else{cell.loadBar!.stopAnimating()}
        }
        return dequeue
    }
    
    /*
     *@param: complaint - String of what the program wants the user know user
     *@desc: Puts the String parameter on a pop up and shows it to the user
     */
    func makeAlert(complaint: String){
        
        let alert = UIAlertController(title: "Alert", message: complaint, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     *@desc: passes user location to the map and then opens map
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location  = locations![indexPath.section]
        let coordinate = CLLocationCoordinate2DMake(location.latitude!, location.longtitude!)
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.02))
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        mapItem.name = location.place!
        mapItem.openInMaps(launchOptions: options)
    }
    
    /*
     *@desc: makes a delete location API call
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            waitingFordata = indexPath.section
            let fullURL =  url + "deleteLocation/" + String(USER!.ID) + "/" + String(describing: locations![indexPath.section].locationID!) +  "/" + USER!.authToken
            makeDeleteLocationRequest(URLInString: fullURL, indexPath: indexPath.section)
            self.tableView.reloadData()
        }
    }
    
    /*
     *@desc: logs out the user from the database and the UI
     */
    @IBAction func logOutButtonClicked(_ sender: UIBarButtonItem) {
        makeLogOutRequest(URLInString: url + "logOut/" + String(USER!.ID) + "/" + USER!.authToken)
        let signInView = self.storyboard!.instantiateViewController(withIdentifier: "StartOfApp")
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        appDelagate.window!.rootViewController = signInView
    }
    
    /*
     *@param: data - API response from the delete location API call
     *@param: indexPath - indexpath being deleted from the array
     *@desc: checks if the data came in ok, and deletes location from array
     */
    func doneMakingRequest(data: Data, indexPath: Int){
        
        do{ //converts the data into redable form
            let jsonUser = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            //gets the status of the response
            if let status = jsonUser["status"] as? String{
                if status == "OK"{//deletes location from arraylist and reloads data
                    locations!.remove(at: indexPath)
                    self.tableView.reloadData()
                    }
                else if status == "TOKENCLEARED"{ //logs user out
                    let signInView = self.storyboard!.instantiateViewController(withIdentifier: "StartOfApp")
                    let appDelagate = UIApplication.shared.delegate as! AppDelegate
                    appDelagate.window!.rootViewController = signInView
                }
            }
            else{makeAlert(complaint: "Server Error")}
            }
        catch{makeAlert(complaint: "Error")
        
        }
        
        
    }
    
    //------------------API call---------------//
    
    /*
     *@param: URLInString - String containing the url to make a delete location request
     *@desc: Makes a delete location API call
     */
    func makeDeleteLocationRequest(URLInString: String, indexPath: Int)
    {
        let url:NSURL = NSURL(string: URLInString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "DELETE"
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                    self.makeAlert(complaint: "Please connect to the internet")
                    return
                }
                if let user = data{ self.doneMakingRequest(data: user, indexPath: indexPath)}
                else {self.makeAlert(complaint: "Sorry we are experencing server errors")}
            }
        }
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
                    self.makeAlert(complaint: "Please connect to the internet")
                    return
                }
            }
        }
        task.resume()
    }
}

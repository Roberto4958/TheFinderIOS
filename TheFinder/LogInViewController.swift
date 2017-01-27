//
//  LogInViewController.swift
//  TheFinder
//
//  Created by roberto on 10/4/16.
//  Copyright © 2016 TheFinder. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!
    private var brain: LogInBrain = LogInBrain()
    private let url = "http://thefinder-1.s4c2qwepti.us-west-2.elasticbeanstalk.com/webresources/logIn/"
    
    
    /*
     * @desc: Checks to see if its safe to make a logIn request from the server
     */
    @IBAction func logInButtonClicked(_ sender: AnyObject) {
        
        if !Reachability().isConnectedToNetwork(){ //check if user is connected to the internet
            makeAlert(complaint: "Please connect to the internet")
            return
        }
        //checks if users data is able to pass through the API call
        if let safe = brain.LogInButtionClicked(userName: userName.text!, pass: password.text!){ makeAlert(complaint: safe)}
        else{
            loadBar.startAnimating()
            logIn_request(URLInString: url + userName.text! + "/" + password.text!)
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
     *@param: data - server response (json format) from making a login request
     *desc: Takes the response from the server converts it to readable data and passes it to the next view
     */
    func doneMakingRequest(data: Data){
        
        do{ //converts the data into a readable format
            let jsonUser = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            //Checks the status of response
            if let status = jsonUser["status"] as? String{
                if status == "OK"{
                    //trurns data into a User object
                    if let userInfo = jsonUser["userInfo"] as? NSDictionary{
                        print(userInfo)
                        let id = userInfo["ID"]
                        let auth = userInfo["authToken"]
                        let firstName = userInfo["firstName"]
                        let lastName = userInfo["lastName"]
                        let userName = userInfo["userName"]
                        
                        
                        let user = User(user: userName as! String, first: firstName as! String, last: lastName as! String, token: auth as! String, id: id as! Int)
                    
                        performSegue(withIdentifier: "GoUser", sender: user)
                    }
                    //if status == OK but does not return UserInfo then that means the user name and password dont match
                    else{ makeAlert(complaint: "Wong user name or password")}
                }
                //in this case the status = ERROR so that means there was a server error
                else {makeAlert(complaint: "Server Error")}
            }
        }
        catch{ makeAlert(complaint: "Error: please report this error")}
    }
    
    /*
     *@param: sender - holds a User object
     *@desc: Passes the users object to the next viewController
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "GoUser"{
            if let destination = segue.destination as? UserViewController{
                destination.USER = sender as? User
            }
        }
    }
    
    /*
     *@desc: When view desapears clears the user input and stops anamating the spinner
     */
    override func viewDidDisappear(_ animated: Bool) {
        userName.text! = "";
        password.text! = "";
        loadBar.stopAnimating()
        
    }
    
    /*
     *@desc: Hides spinner, and Loads tap gesture to dismiss keyboard annamation
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBar.stopAnimating()
        //alows the user to escape from the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    /*
     *@desc: Allows the user to escape from the keyboard
     */
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //-------------------------- API calls ---------------//
    
    /*
     *@param: URLInString - String containing the url to make a Log in request
     *@desc: makes a logIn request
     */
    func logIn_request(URLInString: String)
    {
        
        let url:NSURL = NSURL(string: URLInString)!
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let user = data{ self.doneMakingRequest(data: user)}
                else {self.makeAlert(complaint: "Error: please report this error")}
            }
        }
        task.resume()
    }
}

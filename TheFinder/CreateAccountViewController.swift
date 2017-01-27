//
//  CreateAccountViewController.swift
//  TheFinder
//
//  Created by roberto on 10/5/16.
//  Copyright © 2016 TheFinder. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    private var url = "http://thefinder-1.s4c2qwepti.us-west-2.elasticbeanstalk.com/webresources/createAccount/"
    var brain: CreateAccountBrain = CreateAccountBrain()
    
    @IBOutlet weak var loadBar: UIActivityIndicatorView!

    /*
     *@desc: Makes API call if the user puts in the right information
     */
    @IBAction func SignUpButtonClicked(_ sender: AnyObject) {
        
        if !Reachability().isConnectedToNetwork(){ //check if user is connected to the internet
            makeAlert(complaint: "Please connect to the internet")
            return
        }
        // checks if user input is safe to use to make a create account API call
        if let isNotSafe = brain.signUpButtionClicked(userName: userName.text!, firstname: firstName.text!, lastName: lastName.text!, pass: password.text!){makeAlert(complaint: isNotSafe)}
        
        else{makeCreateAccountRequest(URLInString: url + userName.text! + "/" + password.text! + "/" + firstName.text! + "/" + lastName.text!)}
    }
    
    /*
     *@desc: hides spinner, and adds tap gesture
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBar.stopAnimating()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    /*
     * @desc: Causes the view (or one of its embedded text fields) to resign the first responder status.
     */
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*
     *@desc: Hides spinner
     */
    override func viewDidDisappear(_ animated: Bool) {
        loadBar.stopAnimating()
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
     *@param: data - API response from the create account API call
     *@desc: checks if the data came in ok, and passes it to the TableView controll
     */
    func doneMakingRequest(data: Data){
        do{ //converts the data into redable form 
            let jsonUser = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            //gets the status of the response
            if let status = jsonUser["status"] as? String{
                if status == "OK"{
                    //converts response into a User Object
                    if let userInfo = jsonUser["userInfo"] as? NSDictionary{
                        let id = userInfo["ID"]
                        let auth = userInfo["authToken"]
                        let firstName = userInfo["firstName"]
                        let lastName = userInfo["lastName"]
                        let userName = userInfo["userName"]
                        let user = User(user: userName as! String, first: firstName as! String, last: lastName as! String, token: auth as! String, id: id as! Int)
                        performSegue(withIdentifier: "navigateToUser", sender: user)
                    }
                    else{
                        makeAlert(complaint: "Please choose another user name, it is already taken")
                    }
                }
                else{makeAlert(complaint: "Server Error")}
            }
        }
        catch{
            makeAlert(complaint: "Sorry, we are experincing server errors")
        } 
    }
    
    /*
     *@param: sender - User object with users information
     *@desc: Sendes a User Object to the UserViewController
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateToUser"{
            if let destination = segue.destination as? UserViewController{
                destination.USER = sender as? User
            }
        }
    }
    
    //------------------API call---------------//
    
    /*
     *@param: URLInString - String containing the url to make a create account request
     *@desc: Makes a create account API call
     */
    func makeCreateAccountRequest(URLInString: String)
    {
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

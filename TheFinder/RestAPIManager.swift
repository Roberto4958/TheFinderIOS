//
//  RestAPIManager.swift
//  TheFinder
//
//  Created by roberto on 1/16/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import Foundation

class RestAPIManager{
    
//    func makeHTTPGetRequest(path: String){
//        
//        let url = URLRequest(url: URL(fileURLWithPath: path))
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        let task = session.dataTask(with: url)
//        task.resume()
//    }
    func data_request(url_to_request: String)
    {
        
        let url:NSURL = NSURL(string: url_to_request)!
        //let session = NSURLSession.sharedSession()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString ?? "did not work")
            
        }
        
        task.resume()
        
    }

}

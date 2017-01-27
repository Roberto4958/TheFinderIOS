//
//  User.swift
//  TheFinder
//
//  Created by roberto on 1/13/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import Foundation

class User{
    
    var userName: String
    var firstName: String
    var lastName: String
    var authToken: String
    var ID: Int
    
    init(user: String, first: String, last: String,token: String, id: Int){
        userName = user;
        firstName = first;
        lastName = last;
        authToken = token;
        ID = id;
    }

}

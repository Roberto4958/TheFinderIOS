//
//  LogInBrain.swift
//  TheFinder
//
//  Created by roberto on 1/17/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import Foundation

class LogInBrain{
    
//    private var logInView: LogInViewController? = nil
//
//    
//    func LogInBrain(se: LogInViewController){
//        logInView = se
//        logInView!.performSegue(withIdentifier: "GoUser", sender: nil)
//    }
    
    /*
     *@desc: checks if users input is safe to pass through the RESTfulAPI
     *@return: a String esxplaining whats wrong with the String, but if the String is safe it returns nil
     */
    func LogInButtionClicked(userName: String, pass: String)->String?{
        let safeToProcced: String? = nil
        
        if let errerMessage = checkForInvalidChar(word: userName){
            return errerMessage
        }
        
        if let errerMessage = checkForInvalidChar(word: pass){
            return errerMessage
        }
        
        return safeToProcced
    }
    
    /*
     *@desc: checks if the parameter is safe to pass through the RESTfulAPI
     *@return: a String esxplaining whats wrong with the String, but if the String is safe it returns nil
     */
    func checkForInvalidChar(word: String) ->  String? {
        if word.characters.count == 0{ return "Please fill out all text fields"}
        if word.contains(" ") {return "Please do not use spaces"}
        if containsPunctuation(word: word) {return "Please do not use punctuation"}//(NSCharacterSet.punctuationCharacters)
        return nil
    }
    
    /*
     *@desc: checks if the String parameter contains any punctiation
     *@return: returns true if String contains punctuation, if not returns false
     */
    func containsPunctuation(word: String)->Bool{
    
        let punc = NSCharacterSet.punctuationCharacters
        let rang = word.rangeOfCharacter(from: punc)
        if let hasPunc = rang { return true }
        return false
    }
    

    
}

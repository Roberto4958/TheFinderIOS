//
//  Location.swift
//  TheFinder
//
//  Created by roberto on 1/17/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import Foundation

class Location {

      var latitude: Double? = nil
      var longtitude: Double? = nil
      var locationID:Int? = nil
      var place: String? = nil
    
    init(lat: Double, longt: Double, lID: Int, p: String){
        place = p;
        latitude = lat;
        longtitude = longt;
        locationID = lID;
    }
}

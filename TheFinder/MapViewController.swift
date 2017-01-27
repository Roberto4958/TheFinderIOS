//
//  MapViewController.swift
//  TheFinder
//
//  Created by roberto on 10/16/16.
//  Copyright © 2016 TheFinder. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var location: Location? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let loc = location {
            
            print("In map view at: " + loc.place!)
    
            let loc = CLLocationCoordinate2DMake(loc.latitude!, loc.longtitude!)
            
            
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(loc, 200, 200), animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            mapView.addAnnotation(annotation)
            
            
            
        }
        else {print("location is null")}
        
       
        
    }
    
    @IBAction func logOutButtonClicked(_ sender: UIBarButtonItem) {
        let signInView = self.storyboard!.instantiateViewController(withIdentifier: "StartOfApp")
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        appDelagate.window!.rootViewController = signInView
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

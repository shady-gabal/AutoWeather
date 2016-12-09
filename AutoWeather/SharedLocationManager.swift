//
//  SharedLocationManager.swift
//  AutoWeather
//
//  Created by Shady Gabal on 11/18/16.
//  Copyright © 2016 Shady Gabal. All rights reserved.
//

import UIKit
import CoreLocation

class SharedLocationManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = SharedLocationManager()
    
    var locationManager:CLLocationManager = CLLocationManager()
    var currentUserLocation:CLLocation?
    var requestCallback:(() -> Void)?
    
    override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        if SharedLocationManager.haveAccess(){
            locationManager.startUpdatingLocation()
        }
    }
    
    static func haveAccess() -> Bool{
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways
    }
    
    static func requestedAccess() -> Bool{
        return CLLocationManager.authorizationStatus() != CLAuthorizationStatus.notDetermined
    }
    
    func requestAccess(callback:(() -> Void)?){
        self.requestCallback = callback
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if SharedLocationManager.haveAccess(){
            locationManager.startUpdatingLocation()
        }
        
        if requestCallback != nil {
            requestCallback!()
            requestCallback = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentUserLocation = locations.last
    }
    
}

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
    
    
    static let ReceivedFirstLocation = Notification.Name("ReceivedFirstLocation")
    
    override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        if haveAccess(){
            locationManager.startUpdatingLocation()
        }
    }
    
    func haveAccess() -> Bool{
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways
    }
    
    func requestedAccess() -> Bool{
        return CLLocationManager.authorizationStatus() != CLAuthorizationStatus.notDetermined
    }
    
    func requestAccess(callback:(() -> Void)?){
        self.requestCallback = callback
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if haveAccess(){
            locationManager.startUpdatingLocation()
        }
        
        if requestCallback != nil {
            requestCallback!()
            requestCallback = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
//        let newLocation = CLLocation(latitude: 20.593684, longitude: 78.962880)
        
        let old = self.currentUserLocation
        self.currentUserLocation = newLocation
        if old == nil {
            NotificationCenter.default.post(name: SharedLocationManager.ReceivedFirstLocation, object: nil)
        }
    }
    
}

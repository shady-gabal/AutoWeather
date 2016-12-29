//
//  Globals.swift
//  AutoWeather
//
//  Created by Shady Gabal on 11/18/16.
//  Copyright © 2016 Shady Gabal. All rights reserved.
//

import Foundation
import UIKit

struct Globals{
    static let BASE_URL = "http://3d4c8cf1.ngrok.io"
//    static let BASE_URL = "https://autoweather.herokuapp.com"

    static func showAlert(withTitle:String!, message:String!, actions:UIAlertAction?..., onViewController:UIViewController!){
        
        let alert:UIAlertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        
        if actions.count > 0 && actions[0] != nil{
            for action in actions{
                alert.addAction(action!)
            }
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(okAction)
        }
        
        onViewController.present(alert, animated: true, completion: nil)
    }

    static func secretKey() -> String? {
       return UserDefaults.standard.string(forKey: "secret_key")
    }
    
    static func saveSecretKey(newSecretKey:String) {
        UserDefaults.standard.set(newSecretKey, forKey: "secret_key")
    }
    
    static func saveLocality(locality:String?) {
        if locality != nil {
            UserDefaults.standard.set(locality, forKey: "locality")
        }
    }
    
    static func savedLocality() -> String? {
        return UserDefaults.standard.string(forKey: "locality")
    }
    
    static func uuid() -> String {
      return (UIDevice.current.identifierForVendor?.uuidString)!
    }

}

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

}

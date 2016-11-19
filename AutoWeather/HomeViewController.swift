//
//  ViewController.swift
//  AutoWeather
//
//  Created by Shady Gabal on 11/18/16.
//  Copyright © 2016 Shady Gabal. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var locationCityLabel: UILabel!
    @IBOutlet weak var notifyDatePicker: UIDatePicker!
    @IBOutlet weak var rainSnowSwitch: UISwitch!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !SharedLocationManager.requestedAccess(){

            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                SharedLocationManager.sharedInstance.requestAccess()
            })
            Globals.showAlert(withTitle: "Location Access", message: "Hey! We're about to ask if we can use your location. Without your location, we won't be able to see the weather near you.", actions: okAction, onViewController: self)
        
        }
    }


}


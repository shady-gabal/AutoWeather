//
//  ViewController.swift
//  AutoWeather
//
//  Created by Shady Gabal on 11/18/16.
//  Copyright © 2016 Shady Gabal. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import OneSignal

class HomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationCityLabel: UILabel!
    @IBOutlet weak var notifyDatePicker: UIDatePicker!
    @IBOutlet weak var rainSnowSwitch: UISwitch!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var movieView: UIView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var avPlayer:AVPlayer?
    
    private var requesting:Bool = false
    private var locality:String?
    private var zipcode:String?
    private var country:String?
    
    private var _busy:Bool = false
    private var busy:Bool {
        set{
            if newValue {
                self.saveButton.isHidden = true
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
            }
            else{
                self.saveButton.isHidden = false
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
            _busy = newValue
        }
        get{
            return _busy
        }
    }
    
    var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
    var localTimeZoneAbbreviation: String { return (NSTimeZone.local as! NSTimeZone).name}

    static let VideoName = "clouds.mp4"
    
    private enum DatePickerProperties: String {
        case TextColor = "textColor"
        case HighlightsToday = "highlightsToday"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        activityIndicator.isHidden = true
    
        self.notifyDatePicker.setValue(UIColor.white, forKey: "textColor")
        self.notifyDatePicker.setValue(false, forKey: DatePickerProperties.HighlightsToday.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedFirstLocation), name: SharedLocationManager.ReceivedFirstLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(play), name:         NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name:         NSNotification.Name.UIApplicationWillResignActive, object: nil)
        self.locationCityLabel.text = Globals.savedLocality() ?? ""
//        self.notifyDatePicker.minuteInterval = 60
    }
    
    @objc func receivedFirstLocation(){
        checkLocality()
    }
    
    
    func checkLocality(){
        if SharedLocationManager.sharedInstance.currentUserLocation != nil {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(SharedLocationManager.sharedInstance.currentUserLocation!, completionHandler: {(placemarks, error) -> Void in
                
                if (error != nil) {
                    print(error ?? "no error")
                }
                else {
                    if let placemark = placemarks?.first {
                        var locality = placemark.subLocality != nil ? placemark.subLocality : placemark.subAdministrativeArea
                        locality = locality ?? placemark.locality
                        
                        self.locality = locality
                        Globals.saveLocality(locality: locality)
                        
                        self.locationCityLabel.text = self.locality
                        self.country = placemark.country
                        self.zipcode = placemark.postalCode
                    }
                }
            })
        }
    }

    //MARK: Video Player
    
    func setupVideoPlayer(){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let videoKeys = HomeViewController.VideoName.components(separatedBy: ".")
            let videoName = videoKeys[0]
            let videoType = videoKeys[1]
            
            if let videoPath = Bundle.main.path(forResource: videoName, ofType:videoType){
                let videoUrl = URL(fileURLWithPath: videoPath)
                
                let asset = AVAsset(url: videoUrl)
                let playerItem = AVPlayerItem(asset: asset)
                self.avPlayer = AVPlayer(playerItem: playerItem)
                let avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
                avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                avPlayerLayer.frame = UIScreen.main.bounds
                self.movieView.layer .addSublayer(avPlayerLayer)
                
                self.avPlayer?.seek(to: kCMTimeZero)
                self.avPlayer?.volume = 0.0
                self.avPlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name:Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                
            }
            
            
        }
        catch{
            
        }
    }
    
    func play(){
        self.avPlayer?.play()
        self.avPlayer?.rate = 0.85
    }
    
    func pause(){
        self.avPlayer?.pause()
    }
    
    @objc func playerStartPlaying(notification:Notification) {
        play()
    }
    
    func playerItemDidReachEnd() {
        self.avPlayer?.currentItem?.seek(to:kCMTimeZero)
//        play()
    }
    
    //MARK: Base Methods
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
//        play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fadeIn()
 
    }
    
    @objc func askPermissions(){
        if !SharedLocationManager.sharedInstance.requestedAccess(){
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                SharedLocationManager.sharedInstance.requestAccess(callback: {() in
                    OneSignal.registerForPushNotifications()
                })
            })
            
            Globals.showAlert(withTitle: "Need Permissions", message: "Hey! We're about to ask if we can use your location and send you notifications. The app needs both in order to work.", actions: okAction, onViewController: self)
            
        }
    }

    //MARK: Text Field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Keyboard Animation
    
    func keyboardWillShow(notification:NSNotification){
        if TARGET_IPHONE_SIMULATOR <= 0 {
            let info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            animateViewUp(keyboardHeight: keyboardFrame.size.height)
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        if TARGET_IPHONE_SIMULATOR <= 0 {
            let info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            
            animateViewDown(keyboardHeight: keyboardFrame.size.height)
        }
    }
    
    func animateViewUp(keyboardHeight:CGFloat){
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame.origin.y -= keyboardHeight
        }, completion: nil)
    }
    
    func animateViewDown(keyboardHeight:CGFloat){
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame.origin.y += keyboardHeight
        }, completion: nil)
    }
    
    //MARK: Saving
    
    func alertTime() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        
        let date = self.notifyDatePicker.date
        let str = formatter.string(from: date)
        
        return str
    }

    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if !SharedLocationManager.sharedInstance.haveAccess() {
            Globals.showAlert(withTitle: "Need location permission", message: "Looks like you have disabled location permission. Before we can find the weather near you, you'll need to go to Settings and enable it.", actions: nil, onViewController: self)
        }
        else if !UIApplication.shared.isRegisteredForRemoteNotifications {
            Globals.showAlert(withTitle: "Need notifications permission", message: "Looks like you have disabled push notifications permission. Before we can find the weather near you, you'll need to go to Settings and enable it.", actions: nil, onViewController: self)
        }
        else if !self.busy {
            let alertTime = self.alertTime()
            let comps = alertTime.components(separatedBy: ":")
            let hour = Int(comps[0])
            let minsStr = comps[1].substring(to: alertTime.index(comps[1].startIndex, offsetBy: 2))
            let mins = Int(minsStr)
            let ampm = alertTime.substring(from: alertTime.index(alertTime.endIndex, offsetBy: -2))
            
            if (hour != nil && mins != nil && (hour! < 3 || hour! == 12) && ampm == "AM"){
                Globals.showAlert(withTitle: "Error", message: "We currently aren't able to notify you before 3:00AM. Please select a time at or after 3:00AM", actions: nil, onViewController: self)
                return
            }
            
            var params:Dictionary<String, Any> = [:]
            
            params["notification_time"] = alertTime
            params["seconds_from_utc"] = secondsFromGMT
            params["timezone"] = localTimeZoneAbbreviation
            params["os"] = "ios"
            params["uuid"] = Globals.uuid()
            if zipcode != nil {
                params["zipcode"] = zipcode
            }
            if (country != nil){
                params["country"] = country
            }

            OneSignal.idsAvailable({ (userId, pushToken) in
                
                if userId != nil {
                    params["onesignal_id"] = userId
                }
                if pushToken != nil {
                    params["push_token"] = pushToken
                }
                
                var url = "/users/update"
                
                if Globals.secretKey() == nil {
                    url = "/users/new"
                }
                
                self.busy = true
                
                NetworkManager.sharedInstance.networkRequest(urlString: "\(Globals.BASE_URL)\(url)", method: .POST, parameters: params, successCallback: {(responseObject) -> Void in
                    
                    self.busy = false
                    
                    if let json = responseObject as? Dictionary<String, Any> {
                        if let secretKey = json["secret_key"] as? String {
                            Globals.saveSecretKey(newSecretKey: secretKey)
                        }
                    }
                    
                    Globals.showAlert(withTitle: "Saved", message: "Successfully saved your notification time preference.", actions: nil, onViewController: self)
                    
                    
                }, errorCallback: {(code) -> Void in
                    self.busy = false
                    
                    Globals.showAlert(withTitle: "Error", message: "There was an error reaching the server. Try again in a sec.", actions: nil, onViewController: self)
                })
                    
                
            })

        }
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 1.5, delay: 1, options: .curveLinear, animations: {
            self.saveButton.alpha = 1
            self.notifyDatePicker.alpha = 1
            self.locationCityLabel.alpha = 1
            self.infoLabel.alpha = 1
        }, completion: {(finished) -> Void in
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.askPermissions), userInfo: nil, repeats: false)
        })
    }

}


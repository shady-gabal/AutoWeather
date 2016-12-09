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

class HomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationCityLabel: UILabel!
    @IBOutlet weak var notifyDatePicker: UIDatePicker!
    @IBOutlet weak var rainSnowSwitch: UISwitch!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var movieView: UIView!
    
    private var avPlayer:AVPlayer?
    
    private var requesting:Bool = false
    
    var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
    var localTimeZoneAbbreviation: String { return NSTimeZone.local.abbreviation(for: Date()) ?? ""}

    static let VideoName = "clouds_loop.mp4"
    
    private enum DatePickerProperties: String {
        case TextColor = "textColor"
        case HighlightsToday = "highlightsToday"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoPlayer()
        
        self.notifyDatePicker.setValue(UIColor.white, forKey: "textColor")
        self.notifyDatePicker.setValue(false, forKey: DatePickerProperties.HighlightsToday.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name:Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
                NotificationCenter.default.addObserver(self, selector:#selector(playerStartPlaying), name:Notification.Name.UIApplicationDidBecomeActive, object:nil)
            }
            
            
        }
        catch{
            
        }
    }
    
    func play(){
        self.avPlayer?.play()
        self.avPlayer?.rate = 0.9
    }
    
    @objc func playerStartPlaying(notification:Notification) {
        play()
    }
    
    @objc func playerItemDidReachEnd(notification:Notification) {
        if let p:AVPlayerItem = notification.object as? AVPlayerItem{
            p.seek(to:kCMTimeZero)
        }
        else{
            self.avPlayer?.currentItem?.seek(to:kCMTimeZero)
        }
    }
    
    //MARK: Base Methods
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avPlayer?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SharedLocationManager.sharedInstance
        play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        formatter.dateFormat = "hh:mm aa"
        
        let date = self.notifyDatePicker.date
        let str = formatter.string(from: date)
        
        return str
    }
    
    func getZipcode(callback:@escaping (String?, Error?) -> Void) {
        if SharedLocationManager.sharedInstance.currentUserLocation != nil {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(SharedLocationManager.sharedInstance.currentUserLocation!, completionHandler: {(placemarks, error) -> Void in
                if (error != nil) {
                    print(error ?? "no error")
                    callback(nil, error)
                }
                else{
                    let placemark = placemarks?.first
                    
                    if let postalCode = placemark?.postalCode {
                        callback(postalCode, error)
                    }
                    else{
                        callback(nil, NSError())
                    }
                }

            });
        }
        else{
            callback(nil, NSError())
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if !self.requesting {
            self.requesting = true
            
            var params:Dictionary<String, Any> = [:]
            
            params["notification_time"] = alertTime()
            params["seconds_from_utc"] = secondsFromGMT
            params["timezone"] = localTimeZoneAbbreviation
            
            getZipcode(callback: {(zipcode, error) -> Void in
                
                if zipcode != nil {
                    params["zipcode"] = zipcode
                }

                var url = "/users/new"
                
                if Globals.secretKey() != nil {
                    url = "/users/update"
                }
                
                NetworkManager.sharedInstance.networkRequest(urlString: "\(Globals.BASE_URL)\(url)", method: .POST, parameters: params, successCallback: {(responseObject) -> Void in
                    
                    self.requesting = false
                    print(responseObject ?? "")
                    
                    if let json = responseObject as? Dictionary<String, Any> {
                        if let secretKey = json["secret_key"] as? String {
                            Globals.saveSecretKey(newSecretKey: secretKey)
                        }
                    }
                    
                    
                }, errorCallback: {(code) -> Void in
                    self.requesting = false
                })

            })
        }
    }
    

}


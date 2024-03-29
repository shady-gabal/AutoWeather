//
//  AppDelegate.swift
//  AutoWeather
//
//  Created by Shady Gabal on 11/18/16.
//  Copyright © 2016 Shady Gabal. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let ONESIGNAL_APP_ID = "a32e8c25-b419-4dd4-89d7-a9c1dc911fb3"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        var onesignalOptions:[String : Any] = [:]
        onesignalOptions[kOSSettingsKeyAutoPrompt] = false
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: AppDelegate.ONESIGNAL_APP_ID, handleNotificationReceived: { (result) in
            
        }, handleNotificationAction: {(result) in
            
            }, settings: onesignalOptions)
        
//        let container = UIView(frame: self.window!.frame)

//        let visual = UIVisualEffectView(effect:  UIBlurEffect(style: .dark))
//        let visual = UIView(frame: self.window!.frame)
//        visual.backgroundColor = UIColor.black
//        visual.alpha = 0.35
//        visual.frame = self.window!.frame

        let p = UIImageView(image: UIImage(named: "clouds_bg"))
        p.frame = self.window!.frame
        p.contentMode = .scaleAspectFill

//        container.addSubview(p)
//        container.addSubview(visual)
        
        self.window?.addSubview(p)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


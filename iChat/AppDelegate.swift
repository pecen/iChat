//
//  AppDelegate.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-18.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // AutoLogin
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                    
                }
            }
        })
        
        func userDidLogin(userId: String) {
            self.startOneSignal()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (notification) in
            let userId = notification.userInfo![kUSERID] as! String
            
            UserDefaults.standard.set(userId, forKey: kUSERID)
            UserDefaults.standard.synchronize()
            
            userDidLogin(userId: userId)
        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: kONESIGNALAPPID)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
                 
            }
        }
        
        locationManagerStart()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
                 
            }
        }

        locationManagerStop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - GoToApp
        
    func goToApp() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "mainApplication") as!
            UITabBarController

        self.window?.rootViewController = mainView
    }

    // MARK: - Location manager
    
    func locationManagerStart() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop() {
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    // MARK: - Location Manger delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
            locationManager = nil
            print("denied location access by user")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinates = locations.last!.coordinate
    }
    
    // MARK: - OneSignal
    
    func startOneSignal() {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let userId = status.subscriptionStatus.userId
        let pushToken = status.subscriptionStatus.pushToken
        
        if pushToken != nil {
            if let playerId = userId {
                UserDefaults.standard.set(playerId, forKey: kPUSHID)
            }
            else {
                UserDefaults.standard.removeObject(forKey: kPUSHID)
            }
            
            UserDefaults.standard.synchronize()
        }
        
        // update OneSignalId
        
        updateOneSignalId()
    }

}


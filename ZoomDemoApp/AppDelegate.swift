//
//  AppDelegate.swift
//  ZoomDemoApp
//
//  Created by Sandeep on 17/05/21.
//

import UIKit
import MobileRTC

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let sdkkey = ""
    let sdkSecret = ""
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupSDK(sdkKey: sdkkey, sdkSecret: sdkSecret)
        
        return true
    }
    
    func setupSDK(sdkKey: String, sdkSecret: String) {
        let context = MobileRTCSDKInitContext()
        context.domain = "zoom.us"
        context.enableLog = false
        
        let sdkInitializedSuccessfully = MobileRTC.shared().initialize(context)
        
        if sdkInitializedSuccessfully == true, let authorizationService = MobileRTC.shared().getAuthService() {
            authorizationService.delegate = self
            authorizationService.clientKey = sdkKey
            authorizationService.clientSecret = sdkSecret
            authorizationService.sdkAuth()
        }
    }
    
    
}
extension AppDelegate : MobileRTCAuthDelegate {
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        switch returnValue {
        case .success:
            print("SDK successfully initialized.")
        case .keyOrSecretEmpty:
            print("SDK Key/Secret was not provided. Replace sdkKey and sdkSecret at the top of this file with your SDK Key/Secret.")
        case .keyOrSecretWrong, .unknown:
            print("SDK Key/Secret is not valid.")
        default:
            print("SDK Authorization failed with MobileRTCAuthError: \(returnValue).")
        }
    }
    func onMobileRTCLoginReturn(_ returnValue: Int) {
        switch returnValue {
        case 0:
            print("Successfully logged in")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
        case 1002:
            print("Password incorrect")
        default:
            print("Could not log in. Error code: \(returnValue)")
        }
    }
    func onMobileRTCLogoutReturn(_ returnValue: Int) {
        switch returnValue {
        case 0:
            print("Successfully logged out")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
        default:
            print("Could not log out. Error code: \(returnValue)")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Obtain the MobileRTCAuthService from the Zoom SDK, this service can log in a Zoom user, log out a Zoom user, authorize the Zoom SDK etc.
        if let authorizationService = MobileRTC.shared().getAuthService() {
            
            // Call logoutRTC() to log the user out.
            authorizationService.logoutRTC()
        }
    }
    
    
}


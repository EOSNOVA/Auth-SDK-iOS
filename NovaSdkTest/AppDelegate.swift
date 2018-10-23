//
//  AppDelegate.swift
//  NovaSdkTest
//
//  Created by SuGyumKim on 11/10/2018.
//  Copyright © 2018 WizardWorks. All rights reserved.
//

import UIKit
import NovaAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NovaAuth.shared.register(dappName: "EOS NOVA SDK TEST APP")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NovaAuth.shared.openURL(url: url)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NovaAuth.shared.applicationDidBecomeActive()
    }
}


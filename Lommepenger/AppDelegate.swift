//
//  AppDelegate.swift
//  Lommepenger
//
//  Created by Chris Searle on 06/06/2019.
//  Copyright © 2019 Chris Searle. All rights reserved.
//

import UIKit
import SbankenClient
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var client: SbankenClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func updateClient() -> SbankenClient? {
        print("Updating client")
        return getClient(true)
    }
    
    func getClient(_ refresh: Bool = false) -> SbankenClient? {
        print("Getting client")
        
        if (client == nil || refresh) {
            print("Creating client")
            
            if let clientID = KeychainWrapper.standard.string(forKey: "clientID"),
            let clientSecret = KeychainWrapper.standard.string(forKey: "clientSecret") {
                
                print("Creating client - data found")
                
                client = SbankenClient(clientId: clientID, secret: clientSecret)
            }
        }
        
        return client
    }
}


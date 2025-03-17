//
//  AppDelegate.swift
//  TimeLapseApp
//
//  Created by Z1 on 24.01.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.isIdleTimerDisabled = true
        let defaults = UserDefaults.standard
        let hasLaunchedKey = "hasLaunchedBefore"

        if !defaults.bool(forKey: hasLaunchedKey) {
            defaults.set(3200, forKey: "selectedISO")
            defaults.set(32, forKey: "selectedShutterSpeed")
            defaults.set(2, forKey: "selectedPeriod")
            defaults.set(true, forKey: hasLaunchedKey)
            defaults.set(3, forKey: "maxZoom")
            defaults.set(1, forKey: "minZoom")
            defaults.synchronize()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


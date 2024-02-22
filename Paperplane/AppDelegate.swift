//
//  AppDelegate.swift
//  Paperplane
//
//  Created by tyler on 2/21/24.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupMyApp()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("Application closed")
    }
    
    private func setupMyApp() {
        print("Application opened")
    }
}

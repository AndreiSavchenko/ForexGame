//
//  AppDelegate.swift
//  ForexGame
//
//  Created by Alla on 2/20/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
        -> Bool {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()

            return true
    }
}

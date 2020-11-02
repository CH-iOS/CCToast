//
//  AppDelegate.swift
//  CCToast
//
//  Created by chenh on 2020/10/15.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window?.backgroundColor = UIColor.white
        let rootViewController = UINavigationController.init(rootViewController: CCTableViewController())
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = .ccGreen
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        return true
    }
}

extension UIColor {
    static var ccGreen :UIColor {
        return UIColor(red: 16.0 / 255.0, green: 159.0 / 255.0, blue: 111.0 / 255.0, alpha: 1.0)
    }
}


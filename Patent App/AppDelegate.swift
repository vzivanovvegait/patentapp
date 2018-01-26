//
//  AppDelegate.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 12/27/17.
//  Copyright © 2017 Vladimir Zivanov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let homeViewController = HomeViewController.makeFromStoryboard()
        let navigationController = homeViewController.embedInNavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationController
        
        return true
    }

    

}


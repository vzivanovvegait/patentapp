//
//  StoryboardInitializable.swift
//  DPS
//
//  Created by Vladimir Zivanov on 12/25/17.
//  Copyright © 2017 Vladimir Zivanov. All rights reserved.
//

import UIKit

protocol StoryboardInitializable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    
    static func makeFromStoryboard() -> Self
    
    func embedInNavigationController() -> UINavigationController
    func embedInNavigationController(navBarClass: AnyClass?) -> UINavigationController
}

extension StoryboardInitializable where Self : UIViewController {
    static var storyboardName: String {
        return "Main"
    }
    
    static var storyboardBundle: Bundle? {
        return nil
    }
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    static func makeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        return storyboard.instantiateViewController(
            withIdentifier: storyboardIdentifier) as! Self
    }
    
    func embedInNavigationController() -> UINavigationController {
        return embedInNavigationController(navBarClass: nil)
    }
    
    func embedInNavigationController(navBarClass: AnyClass?) -> UINavigationController {
        let nav = UINavigationController(navigationBarClass: navBarClass, toolbarClass: nil)
        nav.viewControllers = [self]
        return nav
    }
}

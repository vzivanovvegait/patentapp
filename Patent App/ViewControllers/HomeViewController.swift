//
//  HomeViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/4/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController, StoryboardInitializable {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        
        self.navigationController?.isNavigationBarHidden = true

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func play(_ sender: MenuButton) {
        let categoryViewController = CategoryViewController.makeFromStoryboard()
        self.navigationController?.pushViewController(categoryViewController, animated: true)
    }
}


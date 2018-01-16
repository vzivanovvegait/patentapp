//
//  CategoryViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/11/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class CategoryViewController: UIViewController, StoryboardInitializable {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func story(_ sender: Any) {
        let storyViewController = StoryViewController.makeFromStoryboard()
        self.navigationController?.pushViewController(storyViewController, animated: true)
    }
}

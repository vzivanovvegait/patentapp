//
//  HomeViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/4/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

struct MenuCell {
    let image: UIImage!
    let string: String!
}

final class HomeViewController: UIViewController, StoryboardInitializable {
    
    var menuItems = [MenuCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "elephant"), string: "Elephant is sitting"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "giraffe"), string: "Giraffe is reading a book"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "lion"), string: "Lion is sleeping on the floor"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "monkey"), string: "Monkey is eating banana"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "mouse"), string: "Cat is chasing mouse in the house"))
        
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func play(_ sender: MenuButton) {
        let categoryViewController = CategoryViewController.makeFromStoryboard()
        self.navigationController?.pushViewController(categoryViewController, animated: true)
    }
}


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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuItems = [MenuCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "elephant"), string: "Elephant is sitting"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "giraffe"), string: "Giraffe is reading a book"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "lion"), string: "Lion is sleeping on the floor"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "monkey"), string: "Monkey is eating banana"))
        menuItems.append(MenuCell(image: #imageLiteral(resourceName: "mouse"), string: "Cat is chasing mouse in the house"))
        
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell!.textLabel?.text = "Task \(indexPath.row + 1)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.aString = menuItems[indexPath.row].string.lowercased()
        vc.image = menuItems[indexPath.row].image
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

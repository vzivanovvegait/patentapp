//
//  FlashcardsListViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/2/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class FlashcardsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    var flashcards = [Flashcard]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        backButton.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        tableView.tableFooterView = UIView()
        
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        flashcards = FlashcardsManager.shared.getFlashcards()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addFlashcard(_ sender: Any) {
        let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard().embedInNavigationController()
        self.present(createFlashcardViewController, animated: true, completion: nil)
    }
}

extension FlashcardsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        cell.textLabel?.text = flashcards[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyViewController = StoryViewController.makeFromStoryboard()
//        storyViewController.parts = stories[indexPath.row].parts
//        self.navigationController?.pushViewController(storyViewController, animated: true)
    }
    
}

extension FlashcardsListViewController: StoryboardInitializable {
    
}

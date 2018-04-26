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
    @IBOutlet weak var addButton: UIButton!
    
    var flashcardSet: FlashcardSet!
    
    var flashcards = NSMutableOrderedSet() {
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
        
        addButton.setImage(#imageLiteral(resourceName: "plus_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        tableView.tableFooterView = UIView()
        
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        
        if let set = flashcardSet.flashcards {
            flashcards = set as! NSMutableOrderedSet
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let set = flashcardSet.flashcards {
            flashcards = set as! NSMutableOrderedSet
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addFlashcard(_ sender: Any) {
        DialogUtils.showMoreDialog(self, title: nil, message: nil, choises: ["Add text flashcard", "Add image flashcard"], completion: { (result) in
            if result == "Add text flashcard" {
                let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard()
                createFlashcardViewController.flashcardSet = self.flashcardSet
                let navigationController = createFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            } else if result == "Add image flashcard" {
                let createImageFlashcardViewController = CreateImageFlashcardViewController.makeFromStoryboard()
                createImageFlashcardViewController.flashcardSet = self.flashcardSet
                let navigationController = createImageFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            }
        })
    }
}

extension FlashcardsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        cell.textLabel?.text = (flashcards[indexPath.row] as! Flashcard).name
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
        let flashcardsViewController = FlashcardViewController.makeFromStoryboard()
        if let data = (flashcards[indexPath.row] as! Flashcard).imageData as Data?, let image = UIImage(data: data) {
            flashcardsViewController.image = image
        } else {
            flashcardsViewController.question = (flashcards[indexPath.row] as! Flashcard).question
        }
        flashcardsViewController.answer = (flashcards[indexPath.row] as! Flashcard).answer
        self.navigationController?.pushViewController(flashcardsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            if ((self.flashcards[indexPath.row] as! Flashcard).imageData as Data?) != nil {
                let createImageFlashcardViewController = CreateImageFlashcardViewController.makeFromStoryboard()
                createImageFlashcardViewController.flashcard = (self.flashcards[indexPath.row] as! Flashcard)
                let navigationController = createImageFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            } else {
                let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard()
                createFlashcardViewController.flashcard = (self.flashcards[indexPath.row] as! Flashcard)
                let navigationController = createFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            }
        })
        editAction.backgroundColor = UIColor.blue
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete flashcard?", completion: { (result) in
                if result {
                    if FlashcardsManager.shared.deleteFlashcard(flashcard: (self.flashcards[indexPath.row] as! Flashcard)) {
                        self.flashcards.removeObject(at: indexPath.row)
                        tableView.reloadData()
                    } else {
                        DialogUtils.showWarningDialog(self, title: nil, message: "Error!!!", completion: nil)
                    }
                }
            })
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [editAction, deleteAction]
    }
    
}

extension FlashcardsListViewController: StoryboardInitializable {
    
}

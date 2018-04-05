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
        
        addButton.setImage(#imageLiteral(resourceName: "plus_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
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
        let flashcardsViewController = FlashcardViewController.makeFromStoryboard()
        flashcardsViewController.question = flashcards[indexPath.row].question
        flashcardsViewController.answer = flashcards[indexPath.row].answer
        flashcardsViewController.isOrdered = flashcards[indexPath.row].isOrdered
        self.navigationController?.pushViewController(flashcardsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
//            DialogUtils.showYesNoDialogWithInput(self, title: "Update note", message: nil, positive: "Save", cancel: "Cancel", completion: { (success, text) in
//                if success {
//                    self.notes[indexPath.row].explanation = text
//                    if NoteController.shared.saveNote() {
//                        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
//                    } else {
//                        DialogUtils.showWarningDialog(self, title: nil, message: "Error!!!", completion: nil)
//                    }
//                }
//            })
        })
        editAction.backgroundColor = UIColor.blue
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete flashcard?", completion: { (result) in
                if result {
                    if FlashcardsManager.shared.deleteFlashcard(flashcard: self.flashcards[indexPath.row]) {
                        self.flashcards.remove(at: indexPath.row)
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

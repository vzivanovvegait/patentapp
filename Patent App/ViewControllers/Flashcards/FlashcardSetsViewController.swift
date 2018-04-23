//
//  FlashcardSetsViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/23/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class FlashcardSetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var flashcardSet = [FlashcardSet]() {
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
        
        flashcardSet = FlashcardSetManager.shared.getFlashcardSet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addFlashcardSet(_ sender: Any) {
        DialogUtils.showYesNoDialogWithInput(self, title: "Add flashcard set", message: nil, positive: "Add", cancel: "Cancel") { (result, text) in
            if result, let text = text {
                if FlashcardSetManager.shared.insertFlashcardSet(name: text) {
                    self.flashcardSet = FlashcardSetManager.shared.getFlashcardSet()
                }
            }
        }
    }

}

extension FlashcardSetsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcardSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        cell.textLabel?.text = flashcardSet[indexPath.row].name
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
        let flashcardsListViewController = FlashcardsListViewController.makeFromStoryboard()
        flashcardsListViewController.flashcardSet = flashcardSet[indexPath.row]
        self.navigationController?.pushViewController(flashcardsListViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            DialogUtils.showYesNoDialogWithInput(self, title: "Add flashcard set", message: nil, positive: "Add", cancel: "Cancel", editText: self.flashcardSet[indexPath.row].name) { (result, text) in
                if result, let text = text {
                    self.flashcardSet[indexPath.row].name = text
                    if FlashcardSetManager.shared.saveFlashcardSet() {
                        self.flashcardSet = FlashcardSetManager.shared.getFlashcardSet()
                    }
                }
            }
        })
        editAction.backgroundColor = UIColor.blue
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete set?", completion: { (result) in
                if result {
                    if FlashcardSetManager.shared.deleteFlashcardSet(flashcardSet: self.flashcardSet[indexPath.row]) {
                        self.flashcardSet.remove(at: indexPath.row)
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

extension FlashcardSetsViewController: StoryboardInitializable {
    
}

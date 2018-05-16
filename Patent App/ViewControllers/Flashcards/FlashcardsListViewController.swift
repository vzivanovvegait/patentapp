//
//  FlashcardsListViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/2/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

protocol FlashcardCreationDelegate: class {
    func flashcardCreated(isImage: Bool)
}

final class FlashcardsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var flashcardSet: FlashcardSet!
    var flashcards = [Flashcard]()
    
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
        tableView.register(UINib(nibName: String(describing: FlashcardCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FlashcardCell.self))

        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        
        flashcards = FlashcardsManager.shared.getFlashcards(by: flashcardSet)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addFlashcard(_ sender: Any) {
        DialogUtils.showMoreDialog(self, title: nil, message: nil, choises: ["Add text flashcard", "Add image flashcard"], completion: { (result) in
            if result == "Add text flashcard" {
                let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard()
                createFlashcardViewController.flashcardSet = self.flashcardSet
                createFlashcardViewController.delegate = self
                let navigationController = createFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            } else if result == "Add image flashcard" {
                let createImageFlashcardViewController = CreateImageFlashcardViewController.makeFromStoryboard()
                createImageFlashcardViewController.flashcardSet = self.flashcardSet
                createImageFlashcardViewController.delegate = self
                let navigationController = createImageFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func practice(_ sender: Any) {
        let flashcardsViewController = FlashcardViewController.makeFromStoryboard()
        var flashcardSet = flashcards.filter({$0.isSelected == true })
        
        if flashcardSet.count > 0 {
            DialogUtils.showYesNoDialog(self, title: nil, message: "Shuffle cards?") { (result) in
                if result {
                    flashcardSet.shuffle()
                }
                flashcardsViewController.flashcards = flashcardSet
                self.navigationController?.pushViewController(flashcardsViewController, animated: true)
            }
        } else {
            DialogUtils.showWarningDialog(self, title: nil, message: "Please select at least one flashcard.", completion: nil)
        }
        
    }
}

extension FlashcardsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FlashcardCell.self)) as! FlashcardCell
        cell.flashcard = flashcards[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        cell.buttonActionFlashcardAction = { (flashcard, delete) in
            if delete {
                DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete flashcard?", completion: { (result) in
                    if result {
                        if FlashcardsManager.shared.deleteFlashcard(flashcard: flashcard) {
                            self.flashcards.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        } else {
                            DialogUtils.showWarningDialog(self, title: nil, message: "Error!!!", completion: nil)
                        }
                    }
                })
            } else {
                if (flashcard.imageData as Data?) != nil {
                    let createImageFlashcardViewController = CreateImageFlashcardViewController.makeFromStoryboard()
                    createImageFlashcardViewController.flashcard = self.flashcards[indexPath.row]
                    let navigationController = createImageFlashcardViewController.embedInNavigationController()
                    self.present(navigationController, animated: true, completion: nil)
                } else {
                    let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard()
                    createFlashcardViewController.flashcard = self.flashcards[indexPath.row]
                    let navigationController = createFlashcardViewController.embedInNavigationController()
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        flashcards[indexPath.row].isSelected = !flashcards[indexPath.row].isSelected
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            if (self.flashcards[indexPath.row].imageData as Data?) != nil {
                let createImageFlashcardViewController = CreateImageFlashcardViewController.makeFromStoryboard()
                createImageFlashcardViewController.flashcard = self.flashcards[indexPath.row]
                let navigationController = createImageFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            } else {
                let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard()
                createFlashcardViewController.flashcard = self.flashcards[indexPath.row]
                let navigationController = createFlashcardViewController.embedInNavigationController()
                self.present(navigationController, animated: true, completion: nil)
            }
        })
        editAction.backgroundColor = UIColor.blue
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete flashcard?", completion: { (result) in
                if result {
                    if FlashcardsManager.shared.deleteFlashcard(flashcard: self.flashcards[indexPath.row]) {
                        self.flashcards.remove(at: indexPath.row) //.removeObject(at: indexPath.row)
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

extension FlashcardsListViewController: FlashcardCreationDelegate {
    func flashcardCreated(isImage: Bool) {
        if let set = flashcardSet.flashcards?.array as? [Flashcard] {
            flashcards = set
            tableView.reloadData()
        }
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

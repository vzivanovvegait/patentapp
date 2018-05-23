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
    
    deinit {
        print("deinit")
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
        for flashcard in flashcards {
            flashcard.isSelected = false
        }
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
    
    @IBAction func practiceAll(_ sender: Any) {
        if flashcards.count > 0 {
            play(flashcards: flashcards)
        } else {
            DialogUtils.showWarningDialog(self, title: nil, message: "Flashcards list is empty!", completion: nil)
        }
    }
    
    @IBAction func practice(_ sender: Any) {
        let flashcardSet = flashcards.filter({$0.isSelected == true })
        if flashcardSet.count > 0 {
            play(flashcards: flashcardSet)
        } else {
            DialogUtils.showWarningDialog(self, title: nil, message: "Please select at least one flashcard.", completion: nil)
        }
    }
    
    func play( flashcards: [Flashcard]) {
        let flashcardsViewController = FlashcardViewController.makeFromStoryboard()
        var flashcardSet = flashcards
        
        if flashcardSet.count > 1 {
            DialogUtils.showYesNoDialog(self, title: nil, message: "Shuffle cards?") { (result) in
                if result {
                    flashcardSet.shuffle()
                }
                flashcardsViewController.flashcards = flashcardSet
                self.navigationController?.pushViewController(flashcardsViewController, animated: true)
            }
        } else {
            flashcardsViewController.flashcards = flashcardSet
            self.navigationController?.pushViewController(flashcardsViewController, animated: true)
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
        
        if let name = flashcards[indexPath.row].name {
            cell.flashcardNameLabel.text = name
        } else {
            cell.flashcardNameLabel.text = flashcards[indexPath.row].question
        }
        
        cell.buttonActionFlashcardAction = { [weak self] (flashcard, delete) in
            guard let strongSelf = self else {
                return
            }
            if delete {
                DialogUtils.showYesNoDialog(strongSelf, title: "Delete", message: "Are you sure you want to delete flashcard?", completion: { (result) in
                    if result {
                        strongSelf.flashcardSet.removeFromFlashcards(flashcard)
//                        if FlashcardsManager.shared.deleteFlashcard(flashcard: flashcard) {
                            strongSelf.flashcards.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        FlashcardsManager.shared.saveFlashcard()
//                        } else {
//                            DialogUtils.showWarningDialog(strongSelf, title: nil, message: "Error!!!", completion: nil)
//                        }
                    }
                })
            } else {
                if (flashcard.imageData as Data?) != nil {
                    let createImageFlashcardViewController = CreateImageFlashcardViewController.makeFromStoryboard()
                    createImageFlashcardViewController.flashcard = strongSelf.flashcards[indexPath.row]
                    createImageFlashcardViewController.delegate = self
                    let navigationController = createImageFlashcardViewController.embedInNavigationController()
                    strongSelf.present(navigationController, animated: true, completion: nil)
                } else {
                    let createFlashcardViewController = CreateFlashcardViewController.makeFromStoryboard()
                    createFlashcardViewController.flashcard = strongSelf.flashcards[indexPath.row]
                    createFlashcardViewController.delegate = self
                    let navigationController = createFlashcardViewController.embedInNavigationController()
                    strongSelf.present(navigationController, animated: true, completion: nil)
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
        let cell = tableView.cellForRow(at: indexPath) as! FlashcardCell
        cell.flashcard = flashcards[indexPath.row]
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

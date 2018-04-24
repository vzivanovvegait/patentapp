//
//  CreateImageFlashcardViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/24/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class CreateImageFlashcardViewController: UIViewController, KeyboardHandlerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var answerTextView: UITextView!
    
    var flashcardSet: FlashcardSet!
    
    var flashcard: Flashcard?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        registerForKeyboardNotifications()
        enableDismissKeyboardOnTap()
        
        setupViews()
        
        let closeButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.close))
        navigationItem.leftBarButtonItem = closeButtonItem
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        navigationItem.rightBarButtonItem = barButtonItem
        
        if let flashcard = flashcard {
            nameTextField.text = flashcard.name
            if let placeholderLabel = answerTextView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = true
            }
            answerTextView.text = flashcard.answer
        }
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.white
        
        nameTextField.placeholder = "Flashcard name"
        answerTextView.placeholder = "Answer"
        
        nameTextField.setLeftPaddingPoints(5)
        
        nameTextField.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        answerTextView.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        nameTextField.layer.borderWidth = 1
        answerTextView.layer.cornerRadius = 5
        answerTextView.layer.borderColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        answerTextView.layer.borderWidth = 1
    }
    
    func enableDismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func done() {
//        if let name = nameTextField.text, name != "", let question = questionTextView.text, question != "", let answer = answerTextView.text, answer != "" {
//            if let flashcard = flashcard {
//                flashcard.name = name
//                flashcard.question = question
//                flashcard.answer = answer
//                if FlashcardsManager.shared.saveFlashcard() {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            } else {
//                if FlashcardsManager.shared.insertFlashcard(set: flashcardSet, name: name, question: question, answer: answer) {
//                    DialogUtils.showWarningDialog(self, title: nil, message: "Flashcard is saved.", completion: {
//                        self.dismiss(animated: true, completion: nil)
//                    })
//                }
//            }
//        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CreateImageFlashcardViewController: StoryboardInitializable {
    
}

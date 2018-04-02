//
//  CreateFlashcardViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/2/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class CreateFlashcardViewController: UIViewController, KeyboardHandlerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        enableDismissKeyboardOnTap()

        setupViews()
        
        let closeButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.close))
        navigationItem.leftBarButtonItem = closeButtonItem
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        navigationItem.rightBarButtonItem = barButtonItem

    }
    
    func setupViews() {
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        
        nameTextField.placeholder = "Flashcard name"
        questionTextView.placeholder = "Question"
        answerTextView.placeholder = "Answer"
        
        nameTextField.layer.cornerRadius = 5
        questionTextView.layer.cornerRadius = 5
        answerTextView.layer.cornerRadius = 5
    }
    
    func enableDismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @objc func done() {
        if let name = nameTextField.text, name != "", let question = questionTextView.text, question != "", let answer = answerTextView.text, answer != "" {
            if FlashcardsManager.shared.insertFlashcard(name: name, question: question, answer: answer) {
                DialogUtils.showWarningDialog(self, title: nil, message: "Flashcard is saved.", completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CreateFlashcardViewController: StoryboardInitializable {
    
}

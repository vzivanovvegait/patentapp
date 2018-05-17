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
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    var flashcardSet: FlashcardSet!
    
    var flashcard: Flashcard?
    
    weak var delegate: FlashcardCreationDelegate?
    
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
            if let placeholderLabel = questionTextView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = true
            }
            if let placeholderLabel = answerTextView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = true
            }
            questionTextView.text = flashcard.question
            answerTextView.text = flashcard.answer
        }

    }
    
    func setupViews() {
        view.backgroundColor = UIColor.white
        
        questionTextView.placeholder = "Term"
        answerTextView.placeholder = "Definition"
        
        questionTextView.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        answerTextView.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        questionTextView.layer.cornerRadius = 5
        questionTextView.layer.borderColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        questionTextView.layer.borderWidth = 1
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
        if let question = questionTextView.text, question != "", let answer = answerTextView.text, answer != "" {
            if let flashcard = flashcard {
                flashcard.question = question
                flashcard.answer = answer
                if FlashcardsManager.shared.saveFlashcard() {
                 //   self.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: {
                        self.delegate?.flashcardCreated(isImage: false)
                    })
                }
            } else {
                if FlashcardsManager.shared.insertFlashcard(set: flashcardSet, name: nil, question: question, answer: answer) {
                    DialogUtils.showWarningDialog(self, title: nil, message: "Flashcard is saved.", completion: {
                        self.dismiss(animated: true, completion: {
                            self.delegate?.flashcardCreated(isImage: false)
                        })
                    })
                }
            }
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CreateFlashcardViewController: StoryboardInitializable {
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    var flashcardSet: FlashcardSet!
    
    var flashcard: Flashcard?
    
    let imagePicker = UIImagePickerController()
    
    var imageData:NSData?
    
    weak var delegate: FlashcardCreationDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerSetup()

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
            if let data = flashcard.imageData as Data?, let image = UIImage(data: data) {
                imageData = data as NSData?
                imageView.image = image
            }
            imageView.isHidden = false
            answerTextView.text = flashcard.answer
        } else {
            imageView.isHidden = true
        }
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.white
        
        nameTextField.placeholder = "Flashcard name"
        answerTextView.placeholder = "Answer"
        
        addImageButton.setImage(#imageLiteral(resourceName: "image_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        addImageButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        nameTextField.setLeftPaddingPoints(5)
        
        nameTextField.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        answerTextView.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
//        imageView.layer.cornerRadius = 5
//        imageView.layer.borderColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
//        imageView.layer.borderWidth = 1
        
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
        if let name = nameTextField.text, name != "", let answer = answerTextView.text, answer != "", let data = imageData {
            if let flashcard = flashcard {
                flashcard.name = name
                flashcard.answer = answer
                flashcard.imageData = imageData
                if FlashcardsManager.shared.saveFlashcard() {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                if FlashcardsManager.shared.insertFlashcard(set: flashcardSet, name: name, imageData: data, answer: answer) {
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

    @IBAction func openCamera(_ sender: Any) {
//        DialogUtils.showMultipleChoiceActionSheet(self, anchor: self.view, title: nil, message: nil, choises: ["Camera", "Library"], completion: { (result) in
//            if result == "Camera" {
//                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//                self.present(self.imagePicker, animated: true, completion: nil)
//            }
//            if result == "Library" {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
//            }
//        })
        
    }
}

extension CreateImageFlashcardViewController: StoryboardInitializable {
    
}

extension CreateImageFlashcardViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerSetup() {
        
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.imageView.isHidden = false
            
            imageView.image = image
            
            imageData = UIImageJPEGRepresentation(image, 0.5) as NSData?
            
        }
        
    }
    
}

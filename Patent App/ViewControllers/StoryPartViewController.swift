//
//  StoryPartViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/2/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import TTTAttributedLabel

final class StoryPartViewController: UIViewController {
    
    @IBOutlet weak var scrollView: PatentScrollView!
    
    @IBOutlet weak var storyPartLabel: PatentLabel!
    @IBOutlet weak var storyPartImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var image:UIImage?
    
    var words = [Word]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()
        setData()
        setTapGesture()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTextLabel()
    }
}

extension StoryPartViewController {
    
    fileprivate func setTapGesture() {
        storyPartImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        storyPartImageView.addGestureRecognizer(tapGesture)
        
    }

    @objc func tap() {
        let vc = ZoomImageViewController.makeFromStoryboard()
        vc.image = image
        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func setLabel() {
        storyPartLabel.delegate = self
    }
    
    fileprivate func setImage(image: UIImage) {
        let imageAspect = Float(image.size.width / image.size.height)
        imageViewHeightConstraint.constant = CGFloat(Float(UIScreen.main.bounds.width) / imageAspect)
        storyPartImageView.image = image
    }
    
    func setStoryPart(storyPart: StoryPart) {
        self.image = UIImage(named: storyPart.image)
        words = storyPart.words
    }
    
    func setData() {
        storyPartImageView.image = image
        if let image = image {
            self.setImage(image: image)
        }
        let result = DataUtils.createString(from: words)
        storyPartLabel.setText(result.0)
    }
    
}

extension StoryPartViewController {
    
    func checkStringFromResponse(response: String) -> Bool {
        var isFound = false
        let responseArray = response.components(separatedBy: " ")
        for index in 0..<words.count {
            if words[index].check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: words)
        storyPartLabel.setText(result.0)
    }

}

extension StoryPartViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let index = Int(url.absoluteString) {
            handleResponse(index: index)
        }
    }
    
    func handleResponse(index: Int) {
        switch words[index].wordState {
        case .oneline, .underlined:
            words[index].changeState()
            self.setTextLabel()
        case .firstLastLetter:
            words[index].changeState()
            if words[index].hint != nil {
                DialogUtils.showWarningDialog(self, title: "Clue", message: words[index].hint, completion: nil)
            } else {
                DialogUtils.showWarningDialog(self, title: "Clue", message: "The word has no a clue", completion: nil)
            }
        case .clue:
            DialogUtils.showYesNoDialog(self, title: nil, message: "Are you sure you want to give up and see what it is?", completion: { (result) in
                if result {
                    self.words[index].changeState()
                    self.setTextLabel()
                    self.saveWord(word: self.words[index])
                }
            })
        case .normal:
            saveWord(word: words[index])
        }
    }
    
    func saveWord(word: Word) {
        DialogUtils.showYesNoDialog(self, title: "Save", message: "Do you want to save \(word.mainString.uppercased()) into notes?", completion: { (result) in
            if result {
                self.saveDialog(word: word)
            }
        })
    }
    
    func saveDialog(word: Word) {
        if NoteController.shared.insertNote(word: word.mainString.lowercased(), explanation: word.hint?.lowercased()) {
            DialogUtils.showWarningDialog(self, title: nil, message: "\(word.mainString.uppercased()) has been added in Notes!", completion: nil)
        } else {
            DialogUtils.showWarningDialog(self, title: "Error", message: "\(word.mainString.uppercased()) already exist in Notes!", completion: nil)
        }
    }
}

extension StoryPartViewController: StoryboardInitializable {
    
}

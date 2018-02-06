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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var storyPartLabel: PatentLabel!
    @IBOutlet weak var storyPartImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleSpeechLabel: UILabel!
    
    var image:UIImage? {
        willSet {
            if let image = newValue {
                storyPartImageView.image = image
                self.setImage(image: image)
            }
        }
    }
    
    var words = [Word]() {
        willSet {
            let result = DataUtils.createString(from: newValue)
            storyPartLabel.setText(result.0)
            storyPartLabel.sizeToFit()
        }
    }
    
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()

        // Do any additional setup after loading the view.
    }
    
}

extension StoryPartViewController {
    
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
    
    func setGoogleLabel(text: String) {
        googleSpeechLabel.text = text
    }
}

extension StoryPartViewController {
    
    func checkStringFromResponse(response: String) -> Bool {
        var isFound = false
        let responseArray = response.components(separatedBy: " ")
        for index in 0..<words.count {
            if !words[index].check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: words)
        storyPartLabel.setText(result.0)
//        if result.1 {
//            sendContainerView.removeFirstResponder()
//            self.bottomToolBar.recordAudio(self)
//            FinishController.shared.showFinishView {
//                self.startButton.count = 0
//                FinishController.shared.hideFinishView()
//            }
//        }
    }

}

extension StoryPartViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let index = Int(url.absoluteString) {
            if isRecording {
                handleResponse(index: index)
            } else if words[index].isFound {
                saveWord(word: words[index].mainString)
            }
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
                }
            })
        case .normal:
            saveWord(word: words[index].mainString)
        }
    }
    
    func saveWord(word: String) {
        DialogUtils.showYesNoDialog(self, title: "Save", message: "Are you sure you want to save \(word.uppercased()) into notes?", completion: { (result) in
            if result {
                if NoteController.shared.insertNote(word: word.lowercased(), explanation: "test") {
                    DialogUtils.showWarningDialog(self, title: nil, message: "\(word.uppercased()) has been added in Notes!", completion: nil)
                } else {
                    DialogUtils.showWarningDialog(self, title: "Error", message: "\(word.uppercased()) already exist in Notes!", completion: nil)
                }
            }
        })
    }
}

extension StoryPartViewController: StoryboardInitializable {
    
}

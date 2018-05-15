//
//  StoryPartViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/2/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol StoryPartDelegate: class {
    func timer(isValid: Bool, time: Int)
    func pageSolved()
}

final class StoryPartViewController: UIViewController {
    
    weak var delegate:StoryPartDelegate?
    
    @IBOutlet weak var scrollView: PatentScrollView!
    
    var currentLevel:Level = .easy
    var timer = Timer()
    var seconds: Int = 0
    
    @IBOutlet weak var storyPartLabel: PatentLabel!
    @IBOutlet weak var storyPartImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkmarkContainerView: UIView!
    
    var image:UIImage?
    
    var words: NSOrderedSet!
    
    var index:Int!
    
    var isActive: Bool = false
    
    var isSolved: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        checkmarkContainerView.isHidden = true
        setLabel()
        setData()
        setTapGesture()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTextLabelOnAppear()
        isActive = true
        delegate?.timer(isValid: timer.isValid, time: seconds)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isActive = false
    }
    
    func showLevel() {
        self.showLevelParametar(level: currentLevel).delegate = self
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
    
    func setStoryPart(storyPart: DBStoryPart) {
        self.image = UIImage(named: storyPart.imageURL)
        words = storyPart.words
    }
    
    func setData() {
        storyPartImageView.image = self.image
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
            if let word = words[index] as? DBStoryWord, word.check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
    func setTextLabelOnAppear() {
        let result = DataUtils.createString(from: words)
        if result.1 {
            checkmarkContainerView.isHidden = false
            isSolved = true
        } else {
            checkmarkContainerView.isHidden = true
            isSolved = false
        }
        storyPartLabel.setText(result.0)
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: words)
        if !isSolved {
            if result.1 {
                DialogUtils.showWarningDialog(self, title: "Great job, swipe to the next page!", message: nil, completion: nil)
                delegate?.pageSolved()
                checkmarkContainerView.isHidden = false
                isSolved = true
                timer.invalidate()
                delegate?.timer(isValid: timer.isValid, time: seconds)
                changeConstraint(isFull: true)
            } else {
                checkmarkContainerView.isHidden = true
            }
        }
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
        if let word = words[index] as? DBStoryWord, let state = State(rawValue: word.wordState) {
            switch state {
            case .oneline, .underlined:
                word.changeState()
                self.setTextLabel()
            case .firstLastLetter:
                word.changeState()
                if word.hint != nil {
                    DialogUtils.showWarningDialog(self, title: "Clue", message: word.hint, completion: nil)
                } else {
                    DialogUtils.showWarningDialog(self, title: "Clue", message: "The word has no a clue", completion: nil)
                }
            case .clue:
                DialogUtils.showYesNoDialog(self, title: nil, message: "Are you sure you want to give up and see what it is?", completion: { (result) in
                    if result {
                        word.changeState()
                        self.setTextLabel()
                        self.saveWord(word: word)
                    }
                })
            case .normal:
                saveWord(word: word)
            }
        }
    }
    
    func saveWord(word: DBStoryWord) {
        if word.hint != nil {
            DialogUtils.showYesNoDialog(self, title: "Save", message: "Do you want to save \(word.mainString.uppercased()) into notes?", completion: { (result) in
                if result {
                    self.saveDialog(word: word)
                }
            })
        }
    }
    
    func saveDialog(word: DBStoryWord) {
        if NoteController.shared.insertNote(word: word.mainString.lowercased(), explanation: word.hint?.lowercased()) {
            let navigationController = NotesViewController.makeFromStoryboard().embedInNavigationController()
            self.present(navigationController, animated: true, completion: nil)
        } else {
            DialogUtils.showWarningDialog(self, title: "Error", message: "\(word.mainString.uppercased()) already exist in Notes!", completion: nil)
        }
    }
}


extension StoryPartViewController: LevelDelegate {
    func levelChanged(level: Level) {
        print(level.rawValue)
        currentLevel = level
        timer.invalidate()
        setLevel()
    }
    
    func setLevel() {
        switch currentLevel {
        case .easy:
            delegate?.timer(isValid: timer.isValid, time: seconds)
            changeConstraint(isFull: true)
        case .medium:
            seconds = 60
            delegate?.timer(isValid: timer.isValid, time: seconds)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideImage), userInfo: nil, repeats: true)
        case .hard:
            seconds = 30
            delegate?.timer(isValid: timer.isValid, time: seconds)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideImage), userInfo: nil, repeats: true)
        }
    }
    
    @objc func hideImage() {
        seconds = seconds - 1
        if isActive {
            delegate?.timer(isValid: timer.isValid, time: seconds)
        }
        if seconds == 0 {
            timer.invalidate()
            changeConstraint(isFull: false)
            delegate?.timer(isValid: timer.isValid, time: seconds)
        }
    }
    
    func changeConstraint(isFull: Bool) {
        if isFull {
            if let image = image {
                let imageAspect = Float(image.size.width / image.size.height)
                self.imageViewHeightConstraint.constant = CGFloat(Float(UIScreen.main.bounds.width) / imageAspect)
            }
        } else {
            self.imageViewHeightConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension StoryPartViewController: StoryboardInitializable {
    
}

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
    
    var currentLevel:Level = .easy
    var timer = Timer()
    
    @IBOutlet weak var storyPartLabel: PatentLabel!
    @IBOutlet weak var storyPartImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkmarkContainerView: UIView!
    
    var image:UIImage?
    
    var words = Set<DBStoryWord>()
    
    var index:Int!

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
        if let image = storyPart.imageURL {
            self.image = UIImage(named: image)
        }
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
    
    func setTextLabelOnAppear() {
        let result = DataUtils.createString(from: words)
        if result.1 {
            checkmarkContainerView.isHidden = false
        } else {
            checkmarkContainerView.isHidden = true
            
        }
        storyPartLabel.setText(result.0)
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: words)
        if result.1 {
            DialogUtils.showWarningDialog(self, title: "Great job, swipe to the next page!", message: nil, completion: nil)
            checkmarkContainerView.isHidden = false
        } else {
            checkmarkContainerView.isHidden = true
        }
        storyPartLabel.setText(result.0)
        
        if let image = image {
            let imageAspect = Float(image.size.width / image.size.height)
            changeConstraint(constant: CGFloat(Float(UIScreen.main.bounds.width) / imageAspect))
        }
        setLevel()
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
        if word.hint != nil {
            DialogUtils.showYesNoDialog(self, title: "Save", message: "Do you want to save \(word.mainString.uppercased()) into notes?", completion: { (result) in
                if result {
                    self.saveDialog(word: word)
                }
            })
        }
    }
    
    func saveDialog(word: Word) {
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
            if let image = image {
                let imageAspect = Float(image.size.width / image.size.height)
                changeConstraint(constant: CGFloat(Float(UIScreen.main.bounds.width) / imageAspect))
            }
        case .medium:
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(hideImage), userInfo: nil, repeats: false)
        case .hard:
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hideImage), userInfo: nil, repeats: false)
        }
    }
    
    @objc func hideImage() {
        changeConstraint(constant: 0)
    }
    
    func changeConstraint(constant: CGFloat) {
        self.imageViewHeightConstraint.constant = constant
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension StoryPartViewController: StoryboardInitializable {
    
}

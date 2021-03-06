//
//  FlashcardPartViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 5/15/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol FlashcardPartDelegate: class {
    func timer(isValid: Bool, time: Int)
    func pageSolved()
}

final class FlashcardPartViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: PatentLabel!
    @IBOutlet weak var answerLabel: PatentLabel!
    
    weak var delegate:FlashcardPartDelegate?
    
    var currentLevel:Level = .easy
    var timer = Timer()
    var seconds: Int = 0
    
    var index:Int!
    
    var image:UIImage?
    var question: String?
    var answer: String = ""
    
    var words = [Element]()
    var replacedString: String = ""
    
    var isActive: Bool = false
    
    var strictOrder: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLabels()
        setTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetFlashcard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isActive = false
    }
    
    // Set UI
    
    func setLabels() {
        if let question = question {
            questionLabel.isHidden = false
            imageView.isHidden = true
            questionLabel.setText(DataUtils.createAttributtedString(from: question))
        } else {
            questionLabel.isHidden = true
            imageView.isHidden = false
            imageView.image = image
        }
        answerLabel.delegate = self
    }
    
    fileprivate func setTapGesture() {
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tap() {
        let vc = ZoomImageViewController.makeFromStoryboard()
        vc.image = image
        self.present(vc, animated: true, completion: nil)
    }
}

extension FlashcardPartViewController {
    func setTextLabel() {
        let result = DataUtils.createElementString(from: words, basicString: replacedString)
        answerLabel.setText(result.0)
    }
    
    func checkString(googleString: String) -> Bool {
        var isFound = false
        let arrayOfString = googleString.lowercased().components(separatedBy: " ")
        for string in arrayOfString {
            let array = findString(googleString: string)
            if !array.isEmpty {
                isFound = true
            }
            setTextLabel()
        }
        if isEndOfGame() {
            endOfGame()
        }
        return isFound
    }
    
    func checkOrederedString(googleString: String) -> Bool {
        var isFound = false
        let arrayOfString = googleString.lowercased().components(separatedBy: " ")
        for string in arrayOfString {
            let firstUnfoundWord = words.first(where: {$0.isFound == false})
            if firstUnfoundWord?.text.lowercased() == string {
                firstUnfoundWord?.isFound = true
                isFound = true
            }
        }
        setTextLabel()
        if isEndOfGame() {
            endOfGame()
        }
        return isFound
    }
    
    func isEndOfGame() -> Bool {
        if !words.contains(where: { !$0.isFound }) {
            return true
        }
        return false
    }
    
    func endOfGame() {
        DialogUtils.showWarningDialog(self, title: "Great job!", message: nil, completion: nil)
        delegate?.pageSolved()
        timer.invalidate()
        if question != nil {
            questionLabel.isHidden = false
            imageView.isHidden = true
        } else {
            questionLabel.isHidden = true
            imageView.isHidden = false
        }
        delegate?.timer(isValid: timer.isValid, time: seconds)
    }
    
    func findString(googleString: String) -> [Element] {
        let results = words.filter { $0.text.lowercased() == googleString.lowercased() && $0.isFound == false }
        for result in results {
            result.isFound = true
            result.elementState = .solved
        }
        return results
    }
    
    func findOrderedString(googleString: String) -> Element? {
        let results = words.filter { $0.isFound == false }
        if let result = results.first, result.text.lowercased() == googleString.lowercased() {
            result.isFound = true
            return result
        }
        return nil
    }
    
    func resetFlashcard() {
        words = DataUtils.createArray(sentence: answer)
        replacedString = DataUtils.createAnswerString(from: answer)

        if let question = question {
            questionLabel.setText(DataUtils.createAttributtedString(from: question))
        }
        setTextLabel()
        
        timer.invalidate()
        
        if question != nil {
            questionLabel.isHidden = false
            imageView.isHidden = true
        } else {
            questionLabel.isHidden = true
            imageView.isHidden = false
        }
        
        currentLevel = .easy
        
        isActive = true
        delegate?.timer(isValid: timer.isValid, time: seconds)
    }
    
    func increaseFont() {
        if let question = question {
            questionLabel.setText(DataUtils.createAttributtedString(from: question))
        }
        answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
    }
    
    func showLevel() {
        self.showLevelParametar(level: currentLevel, type: LevelType.flashcard).delegate = self
    }
    
    func showDefinition() {
        answerLabel.setText(DataUtils.createAttributtedString(from: answer))
    }
}

extension FlashcardPartViewController: LevelDelegate {
    func levelChanged(level: Level) {
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
            seconds = 10
            delegate?.timer(isValid: timer.isValid, time: seconds)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hide), userInfo: nil, repeats: true)
        case .hard:
            seconds = 5
            delegate?.timer(isValid: timer.isValid, time: seconds)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hide), userInfo: nil, repeats: true)
        }
    }
    
    @objc func hide() {
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
            if question != nil {
                questionLabel.isHidden = false
                imageView.isHidden = true
            } else {
                questionLabel.isHidden = true
                imageView.isHidden = false
            }
        } else {
            questionLabel.isHidden = true
            imageView.isHidden = true
        }
    }
}

extension FlashcardPartViewController: StoryboardInitializable {
    
}

extension FlashcardPartViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let index = Int(url.absoluteString) {
            handleResponse(index: index)
        }
    }
    
    func handleResponse(index: Int) {
        let element = words[index]
        switch element.elementState {
        case .oneline:
            element.changeState()
            self.setTextLabel()
            if isEndOfGame() {
                endOfGame()
            }
            break
         default:
            break
        }
        
    }
}

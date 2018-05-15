//
//  FlashcardPartViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 5/15/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

protocol FlashcardPartDelegate: class {
    func pageSolved()
}

final class FlashcardPartViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: PatentLabel!
    @IBOutlet weak var answerLabel: PatentLabel!
    
    weak var delegate:FlashcardPartDelegate?
    
    var index:Int!
    
    var image:UIImage?
    var question: String?
    var answer: String = ""
    
    var words = [Element]()
    var replacedString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetFlashcard()
    }
    
    // Set UI
    
    func setLabels() {
        words = DataUtils.createArray(sentence: answer)
        replacedString = DataUtils.createAnswerString(from: answer)
        
        if let question = question {
            questionLabel.isHidden = false
            imageView.isHidden = true
            questionLabel.setText(DataUtils.createAttributtedString(from: question))
        } else {
            questionLabel.isHidden = true
            imageView.isHidden = false
            imageView.image = image
        }
        answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
    }

}

extension FlashcardPartViewController {
    func checkString(googleString: String) -> Bool {
        var isFound = false
        let arrayOfString = googleString.lowercased().components(separatedBy: " ")
        for string in arrayOfString {
            let array = findString(googleString: string)
            for e in array {
                isFound = true
                let ranges = findRanges(for: e.text, in: answer)
                for range in ranges {
                    replacedString.replaceSubrange(range, with: e.text)
                    answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
                    if !words.contains(where: { !$0.isFound }) {
                        DialogUtils.showWarningDialog(self, title: "Great job!", message: nil, completion: nil)
                        delegate?.pageSolved()
                    }
                }
            }
        }
        return isFound
    }
    
    func findString(googleString: String) -> [Element] {
        let results = words.filter { $0.text.lowercased() == googleString.lowercased() && $0.isFound == false }
        for result in results {
            result.isFound = true
        }
        return results
    }
    
    func findRanges(for word: String, in text: String) -> [Range<String.Index>] {
        do {
            let regex = try NSRegularExpression(pattern: "\\b\(word)\\b", options: [])
            
            let fullStringRange = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: fullStringRange)
            return matches.map {
                Range($0.range, in: text)!
            }
        }
        catch {
            return []
        }
    }
    
    func resetFlashcard() {
        words = DataUtils.createArray(sentence: answer)
        replacedString = DataUtils.createAnswerString(from: answer)
        answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
    }
}

extension FlashcardPartViewController: StoryboardInitializable {
    
}

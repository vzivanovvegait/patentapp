//
//  FlashcardViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 4/3/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis
import AudioToolbox

class Element {
    var text: String = ""
    var isSpecial: Bool = false
    var isFound = false
}

final class FlashcardViewController: UIViewController, StoryboardInitializable, KeyboardHandlerProtocol {
    
    @IBOutlet weak var topToolBar: TopToolBar!
    @IBOutlet weak var bottomToolBar: BottomToolBar!
    @IBOutlet weak var sendContainerView: SendContainerView!
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: PatentLabel!
    @IBOutlet weak var answerLabel: PatentLabel!
    
    var image:UIImage?
    var question: String?
    var answer: String = ""
    var words = [Element]()
    
    var audioData: NSMutableData = NSMutableData()
    
    var player: AVAudioPlayer?
    
    var replacedString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        words = DataUtils.createArray(sentence: answer)
        replacedString = DataUtils.createAnswerString(from: answer)

        setTopBar()
        setBottomBar()
        setSendContainer()
        
        setLabels()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setPreferredIOBufferDuration(10)
        } catch {
        }
        
        AudioController.sharedInstance.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
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
        answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
    }
    
    func setSendContainer() {
        sendContainerView.registerView { [weak self] (text) in
            
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.checkString(googleString: text) {
                strongSelf.sendContainerView.removeFirstResponder()
            } else {
               strongSelf.playAudio()
            }
        }
    }
    
    func setTopBar() {
        
        topToolBar.backAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.stop()
            if strongSelf.bottomToolBar.recordButton.isSelected {
                strongSelf.bottomToolBar.recordButton.isSelected = false
            }
            strongSelf.navigationController?.popViewController(animated: true)
        }
        
        topToolBar.restartAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            DialogUtils.showYesNoDialog(strongSelf, title: nil, message: "Start over flashcard?", completion: { (result) in
                if result {
                    strongSelf.words = DataUtils.createArray(sentence: strongSelf.answer)
                    strongSelf.replacedString = DataUtils.createAnswerString(from: strongSelf.answer)
                    strongSelf.answerLabel.setText(DataUtils.createAttributtedString(from: strongSelf.replacedString))
                }
            })
        }
    }
    
    func setBottomBar() {
        
        bottomToolBar.notesButton.isHidden = true
        
        bottomToolBar.keyboardAction = { [weak self] in
            self?.sendContainerView.setFirstResponder()
        }
        
        bottomToolBar.playAction = { [weak self] isPlay in
            if isPlay {
                self?.play()
            } else {
                self?.stop()
            }
        }
        
        bottomToolBar.settingsButton.isHidden = true
        
        bottomToolBar.infoButton.isHidden = true
        
    }

    func play() {
        
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    func stop() {
        print("---------------------------------------------")
        if AudioController.sharedInstance.remoteIOUnit != nil {
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }
    }
    
    func playAudio() {
        
        AudioServicesPlaySystemSound(1521)
        
        let url = Bundle.main.url(forResource: "ErrorAlert", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let errorSound = player else { return }
            
            errorSound.prepareToPlay()
            errorSound.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func appMovedToBackground() {
        save()
    }
    
    func save() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
        }
        
        if bottomToolBar.recordButton.isSelected {
            bottomToolBar.recordButton.isSelected = false
        }
    }

}

extension FlashcardViewController: AudioControllerDelegate {
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if error != nil {
                    strongSelf.stop()
                    strongSelf.play()
                } else if let response = response {
                    
                    print(response)
                    for result in response.resultsArray {
                        guard let result = result as? StreamingRecognitionResult else {
                            return
                        }
                        for alternative in result.alternativesArray {
                            guard let alternative = alternative as? SpeechRecognitionAlternative else {
                                return
                            }
                            strongSelf.bottomToolBar.setGoogleSpeechLabel(text: alternative.transcript)
                            let _ = strongSelf.checkString(googleString: alternative.transcript)
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
//    func checkOrderString(googleString: String) {
//        let arrayOfString = googleString.lowercased().components(separatedBy: " ")
//        for string in arrayOfString {
//            let result = words.filter { $0.isFound == false }.first
//            if let result = result {
//                if result.text == string {
//                    let ranges = findRanges(for: result.text, in: answer)
//                    for range in ranges {
//                        replacedString.replaceSubrange(range, with: result.text)
//                        answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
//                    }
//                }
//            }
//        }
//    }
    
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
                        if bottomToolBar.recordButton.isSelected {
                            bottomToolBar.recordButton.isSelected = false
                        }
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
    
}

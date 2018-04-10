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
    @IBOutlet weak var questionLabel: PatentLabel!
    @IBOutlet weak var answerLabel: PatentLabel!
    
    var question: String = ""
    var answer: String = ""
    var isOrdered: Bool = false
    var words = [Element]()
    
    var audioData: NSMutableData!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    func setLabels() {
        questionLabel.setText(DataUtils.createAttributtedString(from: question))
        answerLabel.setText(DataUtils.createAttributtedString(from: replacedString))
    }
    
    func setSendContainer() {
        sendContainerView.registerView { (text) in
            if self.checkString(googleString: text) {
                self.sendContainerView.removeFirstResponder()
            } else {
               self.playAudio()
            }
        }
    }
    
    func setTopBar() {
        
        topToolBar.backAction = {
            self.navigationController?.popViewController(animated: true)
        }
        
        topToolBar.reloadButton.isHidden = true
    }
    
    func setBottomBar() {
        
        bottomToolBar.notesButton.isHidden = true
        
        bottomToolBar.keyboardAction = {
            self.sendContainerView.setFirstResponder()
        }
        
        bottomToolBar.playAction = { isPlay in
            if isPlay {
                self.play()
            } else {
                self.stop()
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
                }
            }
        }
        return isFound
    }
    
    func findString(googleString: String) -> [Element] {
        let results = words.filter { $0.text.lowercased() == googleString.lowercased() }
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

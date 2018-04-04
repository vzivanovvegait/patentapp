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
    
    func getString() -> String {
        if self.isFound {
            return text
        } else {
            return text.mapString()
        }
    }
    
    func check(array: [String]) -> Bool {
        if checkString(in: array) {
            self.isFound = true
            return true
        } else {
            return false
        }
    }
    
    fileprivate func checkString(in array: [String]) -> Bool {
        return array.contains(where: { $0.uppercased() == text.uppercased() }) ? true : false
    }
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
    var words = [Element]()
    
    var audioData: NSMutableData!
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        words = DataUtils.createArrayOfElements(string: answer)

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
        questionLabel.setText(DataUtils.createQuestionString(from: question))
        let result = DataUtils.createFlashcardString(from: words)
        answerLabel.setText(result.0)
    }
    
    func setSendContainer() {
        sendContainerView.registerView { (text) in
            
            if self.checkStringFromResponse(response: text) {
                let result = DataUtils.createFlashcardString(from: self.words)
                self.answerLabel.setText(result.0)
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
                            
                            if strongSelf.checkStringFromResponse(response: alternative.transcript) {
                                let result = DataUtils.createFlashcardString(from: strongSelf.words)
                                strongSelf.answerLabel.setText(result.0)
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func checkStringFromResponse(response: String) -> Bool {
        var isFound = false
        let responseArray = response.components(separatedBy: " ")
        for word in words {
            if word.check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
}

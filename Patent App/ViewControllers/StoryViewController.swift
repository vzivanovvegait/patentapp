//
//  StoryViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 12/27/17.
//  Copyright © 2017 Vladimir Zivanov. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis
import TTTAttributedLabel

let SAMPLE_RATE = 16000

final class StoryViewController: UIViewController, StoryboardInitializable, KeyboardHandlerProtocol {
    
    var audioData: NSMutableData!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomToolBar: BottomToolBar!
    
    @IBOutlet weak var sendContainerView: SendContainerView!
    
    @IBOutlet weak var label: PatentLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleSpeechLabel: UILabel!
    
    var isRecording = false
    
    var storyParts = [StoryPart]()
    var words = [Word]()
    var storyIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLabel()
        setBottomBar()
        setSendContainer()
        setData()
        enableDismissKeyboardOnTap()
        
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Set data
    
    func setData() {
        storyParts = StoryController.getStory()
        self.setStoryPart()
    }
    
    // Set UI
    
    func setImage(image: UIImage) {
        let imageAspect = Float(image.size.width / image.size.height)
        imageViewHeightConstraint.constant = CGFloat(Float(UIScreen.main.bounds.width) / imageAspect)
        imageView.image = image
    }
    
    func setLabel() {
        label.delegate = self
    }
    
    func setBottomBar() {
        
        bottomToolBar.notesAction = {
            let navigationController = NotesViewController.makeFromStoryboard().embedInNavigationController()
            self.present(navigationController, animated: true, completion: nil)
        }
        
        bottomToolBar.keyboardAction = {
            self.sendContainerView.setFirstResponder()
        }
        
        bottomToolBar.previousAction = {
            self.storyIndex = (self.storyIndex - 1 >= 0) ? self.storyIndex - 1 : self.storyIndex
            self.bottomToolBar.setupPrevNextButtons(index: self.storyIndex, in: self.storyParts.count)
            self.setStoryPart()
        }
        
        bottomToolBar.nextAction = {
            self.storyIndex = (self.storyIndex + 1 < self.storyParts.count) ? self.storyIndex + 1 : self.storyIndex
            self.bottomToolBar.setupPrevNextButtons(index: self.storyIndex, in: self.storyParts.count)
            self.setStoryPart()
        }
        
        bottomToolBar.playAction = { isPlay in
            if isPlay {
                self.play()
            } else {
                self.stop()
            }
        }
    }
    
    func setSendContainer() {
        sendContainerView.registerView { (text) in
            if self.checkStringFromResponse(response: text) {
                self.setTextLabel()
            }
        }
    }
    
    func setStoryPart() {
        setImage(image: UIImage(named: storyParts[storyIndex].image)!)
        words = storyParts[storyIndex].words
        let result = DataUtils.createString(from: words)
        label.setText(result.0)
    }
    
    // Play/Stop actions
    
    func play() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch { }
        
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
        
        isRecording = true
    }
    
    func stop() {
        if AudioController.sharedInstance.remoteIOUnit != nil {
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }
        isRecording = false
    }
    
    // IBActions
    
    @IBAction func back(_ sender: Any) {
        stop()
        self.navigationController?.popViewController(animated: true)
    }
}

extension StoryViewController: AudioControllerDelegate {
    
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
                        guard let result = result as? StreamingRecognitionResult, result.isFinal else {
                            return
                        }
                        for alternative in result.alternativesArray {
                            guard let alternative = alternative as? SpeechRecognitionAlternative else {
                                return
                            }
                            strongSelf.googleSpeechLabel.text = alternative.transcript
                            if strongSelf.checkStringFromResponse(response: alternative.transcript) {
                                strongSelf.setTextLabel()
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
        for index in 0..<words.count {
            if !words[index].check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: words)
        label.setText(result.0)
        if result.1 {
            sendContainerView.removeFirstResponder()
            self.bottomToolBar.recordAudio(self)
            FinishController.shared.showFinishView {
//                self.startButton.count = 0
                FinishController.shared.hideFinishView()
            }

        }
    }
}

extension StoryViewController: TTTAttributedLabelDelegate {
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

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
    @IBOutlet weak var startButton: RecordStopButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var sendContainerView: SendContainerView!
    
    @IBOutlet weak var label: TTTAttributedLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleSpeechLabel: UILabel!
    
    var isRecording = false
    
    var storyParts = [StoryPart]()
    var storyIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storyParts = StoryController.getStory()
        
        setLabel()
        setViews()
        setData()
        
        enableDismissKeyboardOnTap()

        sendContainerView.registerView { (text) in
            if self.checkStringFromResponse(response: text) {
                self.setTextLabel()
            }
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("kraj")
    }
    
    // Set data
    
    func setData() {
        
        storyParts[storyIndex].words = storyParts[storyIndex].words
        setTextLabel()
        
        setImage(image: UIImage(named: storyParts[storyIndex].image)!)
    }
    
    // Set UI
    
    func setImage(image: UIImage) {
        let imageAspect = Float(image.size.width / image.size.height)
        imageViewHeightConstraint.constant = CGFloat(Float(UIScreen.main.bounds.width) / imageAspect)
        imageView.image = image
    }
    
    func setLabel() {
        label.linkAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)]
        label.activeLinkAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)]
        label.delegate = self
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
    }
    
    func setViews() {
        keyboardButton.isEnabled = false
        keyboardButton.setImage(#imageLiteral(resourceName: "ic_keyboard").withRenderingMode(.alwaysTemplate), for: .normal)
        keyboardButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
//        scrollView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 80, right: 0)
        startButton.delegate = self
        notesButton.setImage(#imageLiteral(resourceName: "note").withRenderingMode(.alwaysTemplate), for: .normal)
        notesButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        backButton.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        forwardButton.setImage(#imageLiteral(resourceName: "forward").withRenderingMode(.alwaysTemplate), for: .normal)
        forwardButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
    }
    
    // Play/Stop actions
    
    func play() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
        
        keyboardButton.isEnabled = true
        isRecording = true
    }
    
    func stop() {
        if AudioController.sharedInstance.remoteIOUnit != nil {
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }
        
        keyboardButton.isEnabled = false
        isRecording = false
    }
    
    // IBActions
    
    @IBAction func recordAudio(_ sender: Any) {
        startButton.isSelected = !startButton.isSelected
        if (startButton.isSelected) {
            play()
        } else {
            stop()
        }
    }
    
    @IBAction func keyboard(_ sender: Any) {
        sendContainerView.setFirstResponder()
    }
    
    @IBAction func notes(_ sender: Any) {
        let navigationController = NotesViewController.makeFromStoryboard().embedInNavigationController()
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        stop()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previous(_ sender: Any) {
        storyIndex -= 1
        self.setupPrevNextButtons()
        
        storyParts[storyIndex].words = storyParts[storyIndex].words
        
        setImage(image: UIImage(named: storyParts[storyIndex].image)!)
        
        let result = DataUtils.createString(from: storyParts[storyIndex].words)
        label.setText(result.0)
    }
    
    @IBAction func forward(_ sender: Any) {
        storyIndex += 1
//        self.setData()
        self.setupPrevNextButtons()
        storyParts[storyIndex].words = storyParts[storyIndex].words
        
        setImage(image: UIImage(named: storyParts[storyIndex].image)!)
        
        let result = DataUtils.createString(from: storyParts[storyIndex].words)
        label.setText(result.0)
    }
    
}

extension StoryViewController: RecordStopButtonDelegate {
    func timeExpired() {
        stop()
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
        for index in 0..<storyParts[storyIndex].words.count {
            if !storyParts[storyIndex].words[index].check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: storyParts[storyIndex].words)
        label.setText(result.0)
        if result.1 {
            sendContainerView.removeFirstResponder()
            recordAudio(self)
            FinishController.shared.showFinishView {
                self.storyParts[self.storyIndex].isSolved = true
                self.startButton.count = 0
                FinishController.shared.hideFinishView()
                self.setupPrevNextButtons()
//                if self.index + 1 < self.storyParts.count {
//                    self.index += 1
//                }
//                self.setData()
            }

        }
    }
    
    func setupPrevNextButtons() {
        if storyParts[storyIndex].isSolved {
            if storyIndex + 1 < storyParts.count {
                forwardButton.isEnabled = true
            } else {
                forwardButton.isEnabled = false
            }
        } else {
            forwardButton.isEnabled = false
        }
        if storyIndex > 0 {
            backButton.isEnabled = true
        } else {
            backButton.isEnabled = false
        }
//        if self.index + 1 < self.storyParts.count {
//            forwardButton.isEnabled = true
//        } else {
//            forwardButton.isEnabled = false
//        }
//        if self.index > 0 {
//            backButton.isEnabled = true
//        } else {
//            backButton.isEnabled = false
//        }
//        self.setData()
    }
}

extension StoryViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let index = Int(url.absoluteString) {
            if isRecording {
                handleResponse(index: index)
            } else if storyParts[storyIndex].words[index].isFound {
                DialogUtils.showYesNoDialog(self, title: "Save", message: "Are you sure you want to save \(storyParts[storyIndex].words[index].mainString.uppercased()) into notes?", completion: { (result) in
                    if result {
                        if NoteController.shared.insertNote(word: self.storyParts[self.storyIndex].words[index].mainString.lowercased(), explanation: "test") {
                            DialogUtils.showWarningDialog(self, title: nil, message: "\(self.storyParts[self.storyIndex].words[index].mainString.uppercased()) has been added in Notes!", completion: nil)
                        } else {
                            DialogUtils.showWarningDialog(self, title: "Error", message: "\(self.storyParts[self.storyIndex].words[index].mainString.uppercased()) already exist in Notes!", completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    func handleResponse(index: Int) {
        switch storyParts[storyIndex].words[index].wordState {
        case .oneline:
            storyParts[storyIndex].words[index].changeState()
            self.setTextLabel()
        case .underlined:
            storyParts[storyIndex].words[index].changeState()
            self.setTextLabel()
        case .firstLastLetter:
            storyParts[storyIndex].words[index].changeState()
            if storyParts[storyIndex].words[index].hint != nil {
                DialogUtils.showWarningDialog(self, title: "Clue", message: storyParts[storyIndex].words[index].hint, completion: nil)
            } else {
                DialogUtils.showWarningDialog(self, title: "Clue", message: "The word has no a clue", completion: nil)
            }
        case .clue:
            DialogUtils.showYesNoDialog(self, title: nil, message: "Are you sure you want to give up and see what it is?", completion: { (result) in
                if result {
                    self.storyParts[self.storyIndex].words[index].changeState()
                    self.setTextLabel()
                }
            })
        case .normal:
            DialogUtils.showYesNoDialog(self, title: "Save", message: "Are you sure you want to save \(storyParts[storyIndex].words[index].mainString.uppercased()) into notes?", completion: { (result) in
                if result {
                    if NoteController.shared.insertNote(word: self.storyParts[self.storyIndex].words[index].mainString.lowercased(), explanation: "test") {
                        DialogUtils.showWarningDialog(self, title: nil, message: "\(self.storyParts[self.storyIndex].words[index].mainString.uppercased()) has been added in Notes!", completion: nil)
                    } else {
                        DialogUtils.showWarningDialog(self, title: "Error", message: "\(self.storyParts[self.storyIndex].words[index].mainString.uppercased()) already exist in Notes!", completion: nil)
                    }
                }
            })
            
        }
    }
}

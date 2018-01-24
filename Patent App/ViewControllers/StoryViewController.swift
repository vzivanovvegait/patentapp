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
    
    @IBOutlet weak var sendContainerView: SendContainerView!
    
    @IBOutlet weak var label: TTTAttributedLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    
    var arrayOfWords = [Word]()
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLabel()
        setImage(image: UIImage(named: "1")!)
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
        stop()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("kraj")
    }
    
    // Set data
    
    func setData() {
        arrayOfWords = DataUtils.getDataArray()
        setTextLabel()
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
        scrollView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 80, right: 0)
        startButton.delegate = self
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        for index in 0..<arrayOfWords.count {
            if !arrayOfWords[index].check(array: responseArray) {
                isFound = true
            }
        }
        return isFound
    }
    
    func setTextLabel() {
        let result = DataUtils.createString(from: arrayOfWords)
        label.setText(result.0)
        if result.1 {
            sendContainerView.removeFirstResponder()
            recordAudio(self)
            FinishController.shared.showFinishView {
                self.arrayOfWords = DataUtils.getDataArray()
                self.startButton.count = 0
                FinishController.shared.hideFinishView()
                self.setTextLabel()
            }

        }
    }
}

extension StoryViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let index = Int(url.absoluteString), isRecording {
            switch arrayOfWords[index].wordState {
            case .oneline:
                arrayOfWords[index].changeState()
                self.setTextLabel()
            case .underlined:
                arrayOfWords[index].changeState()
                DialogUtils.showWarningDialog(self, title: "Clue", message: arrayOfWords[index].hint, completion: nil)
//                self.setTextLabel()
            case .clue:
                arrayOfWords[index].changeState()
                self.setTextLabel()
            case .firstLastLetter:
                DialogUtils.showYesNoDialog(self, title: nil, message: "Are you sure you want to give up and see what it is?", completion: { (result) in
                    if result {
                        self.arrayOfWords[index].changeState()
                        self.setTextLabel()
                    }
                })
            case .normal:
                break
            }
        }
    }
}

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
            let arrayOfString = text.components(separatedBy: " ")
            self.label.setText(self.createString(array: arrayOfString))
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
        label.setText(self.createString(array: []))
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
                            
                            let arrayOfString = alternative.transcript.components(separatedBy: " ")
                            
                            strongSelf.label.setText(strongSelf.createString(array: arrayOfString))
                            
                            if let s = StringUtils.checkIsFinish(wordArray: strongSelf.arrayOfWords) {
                                strongSelf.label.text = s
                                strongSelf.recordAudio(strongSelf)
                                FinishController.shared.showFinishView {
                                    strongSelf.arrayOfWords = DataUtils.getDataArray()
                                    strongSelf.label.text = StringUtils.createString(from: strongSelf.arrayOfWords)
                                    strongSelf.startButton.count = 0
                                    
                                     FinishController.shared.hideFinishView()
                                }
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func createString(array: [String]) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: "")
        var rangeCounter = 0
        for index in 0..<arrayOfWords.count {
            if index != 0 {
                if ![".", ",", ":", "?", "!"].contains(arrayOfWords[index].mainString) {
                    attString.append(NSMutableAttributedString(string: " "))
                    rangeCounter += 1
                }
            }
            attString.append(NSMutableAttributedString(string: arrayOfWords[index].getString(array: array)))
            attString.addAttribute(NSAttributedStringKey.link, value: "\(index)", range: NSRange(location: rangeCounter, length: arrayOfWords[index].mainString.count))
            
            rangeCounter += arrayOfWords[index].mainString.count
        }
        
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 34), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        return attString
    }
}

extension StoryViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let index = Int(url.absoluteString), isRecording {
            arrayOfWords[index].changeState()
            label.setText(createString(array: []))
        }
    }
}

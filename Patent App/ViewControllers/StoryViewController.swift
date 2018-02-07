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
    
    let vc:StoryPartViewController = StoryPartViewController.makeFromStoryboard()
    
    var audioData: NSMutableData!
    var timer = Timer()
    
    @IBOutlet weak var bottomToolBar: BottomToolBar!
    @IBOutlet weak var sendContainerView: SendContainerView!
    @IBOutlet weak var storyPartContainerView: UIView!
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    var storyParts = [StoryPart]()
    var storyIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setContainerView()
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
        vc.setStoryPart(storyPart: storyParts[storyIndex])
    }
    
    // Set UI
    
    func setContainerView() {
        self.addChildViewController(vc)
        vc.view.frame = storyPartContainerView.bounds
        storyPartContainerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
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
            self.vc.setStoryPart(storyPart: self.storyParts[self.storyIndex])
        }
        
        bottomToolBar.nextAction = {
            self.storyIndex = (self.storyIndex + 1 < self.storyParts.count) ? self.storyIndex + 1 : self.storyIndex
            self.bottomToolBar.setupPrevNextButtons(index: self.storyIndex, in: self.storyParts.count)
            self.vc.setStoryPart(storyPart: self.storyParts[self.storyIndex])
        }
        
        bottomToolBar.playAction = { isPlay in
            if isPlay {
                self.play()
            } else {
                self.stop()
            }
        }
        
        bottomToolBar.settingsAction = {
            DialogUtils.showMultipleChoiceActionSheet(self, anchor: self.view, title: nil, message: nil, choises: ["Level", "Info"], completion: { (result) in

            })
        }
        
        bottomToolBar.restartAction = {
            DialogUtils.showYesNoDialog(self, title: nil, message: "Are you sure you want to reset this part of the story?", completion: { (result) in
                if result {
                    self.storyParts[self.storyIndex].reset()
                    self.vc.setStoryPart(storyPart: self.storyParts[self.storyIndex])
                }
            })
        }
    }
    
    func setSendContainer() {
        sendContainerView.registerView { (text) in
            if self.vc.checkStringFromResponse(response: text) {
                self.vc.setTextLabel()
            }
        }
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
        
        vc.isRecording = true
    }
    
    func stop() {
        if AudioController.sharedInstance.remoteIOUnit != nil {
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }
        vc.isRecording = false
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
                        guard let result = result as? StreamingRecognitionResult else {
                            return
                        }
                        for alternative in result.alternativesArray {
                            guard let alternative = alternative as? SpeechRecognitionAlternative else {
                                return
                            }
                            strongSelf.vc.setGoogleLabel(text: alternative.transcript)
                            if result.isFinal && strongSelf.vc.checkStringFromResponse(response: alternative.transcript) {
                                strongSelf.timer.invalidate()
                                strongSelf.timer = Timer.scheduledTimer(timeInterval: 2, target: strongSelf, selector: #selector(strongSelf.counter), userInfo: nil, repeats: false)
                                strongSelf.vc.setTextLabel()
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    @objc func counter() {
        vc.setGoogleLabel(text: "")
    }

}


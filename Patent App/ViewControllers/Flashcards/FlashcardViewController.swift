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

final class FlashcardViewController: UIViewController, StoryboardInitializable, KeyboardHandlerProtocol {
    
    @IBOutlet weak var topToolBar: TopToolBar!
    @IBOutlet weak var bottomToolBar: BottomToolBar!
    @IBOutlet weak var sendContainerView: SendContainerView!
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    var audioData: NSMutableData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTopBar()
        setBottomBar()
        
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
    
    func setTopBar() {
        
        topToolBar.backAction = {
            self.navigationController?.popViewController(animated: true)
        }
        
        topToolBar.restartAction = {
            
        }
    }
    
    func setBottomBar() {
        
        bottomToolBar.notesAction = {
        }
        
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
        
        bottomToolBar.settingsAction = {
        }
        
        bottomToolBar.infoAction = {
            
        }
        
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
//                            if /*result.isFinal &&*/ strongSelf.viewControllers[strongSelf.storyIndex].checkStringFromResponse(response: alternative.transcript) {
//                                strongSelf.viewControllers[strongSelf.storyIndex].setTextLabel()
//                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
}

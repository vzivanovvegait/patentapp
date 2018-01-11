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

let SAMPLE_RATE = 16000

final class StoryViewController: UIViewController, StoryboardInitializable {
    
    var audioData: NSMutableData!
    
    @IBOutlet weak var startButton: RecordStopButton!
    @IBOutlet weak var hintButton: HintButton!
    @IBOutlet weak var ovalView: OvalView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var aString:String! = "my brother's room"
    var image:UIImage!
    var stringArray = [String]()
    
    var hintNumber: Int? = 5
    
    var replacedString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.delegate = self
        imageView.image = #imageLiteral(resourceName: "elephant")
        
        hintButton.setImage(#imageLiteral(resourceName: "hint").withRenderingMode(.alwaysTemplate), for: .normal)
        hintButton.badge = hintNumber
        ovalView.isHidden = true
        ovalView.text = "What animal is on image?"
        
        AudioController.sharedInstance.delegate = self
        
        stringArray = aString.lowercased().components(separatedBy: " ")
        
        replacedString = String(aString.map {
            if (($0 >= "a" && $0 <= "z") || ($0 >= "A" && $0 <= "Z")) {
                return "_"
            } else {
                return $0
            }
        })
        
        label.text = replacedString
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stop()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            play()
        } else {
            stop()
        }
    }
    
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
    }
    
    func stop() {
        if AudioController.sharedInstance.remoteIOUnit != nil {
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }
    }
    
    @IBAction func hintNumberAction(_ sender: HintButton) {
        if var badge = hintNumber {
            ovalView.isHidden = false
            badge = badge - 1
            sender.badge = badge
        }
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
                            
//                            strongSelf.label.text = alternative.transcript
                            let arrayOfString = alternative.transcript.lowercased().components(separatedBy: " ")
                            for string in arrayOfString {
                                let ranges = strongSelf.findRanges(for: string, in: strongSelf.aString)
                                for range in ranges {
                                    strongSelf.replacedString.replaceSubrange(range, with: string)
                                    strongSelf.label.text = strongSelf.replacedString.uppercased()
                                }
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
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

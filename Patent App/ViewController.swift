//
//  ViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 12/27/17.
//  Copyright © 2017 Vladimir Zivanov. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis

let SAMPLE_RATE = 16000

class ViewController: UIViewController {
    
    var audioData: NSMutableData!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var aString:String! // = "Elephant is sitting"
    var image:UIImage!
    var stringArray = [String]()
    
    var replacedString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        AudioController.sharedInstance.delegate = self
        
        stringArray = aString.lowercased().components(separatedBy: " ")
        
        replacedString = String(aString.map {
            $0 != " " ? "_" : " "
        })
        
        label.text = replacedString
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
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
}

extension ViewController: AudioControllerDelegate {
    
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
                        guard let result = result as? StreamingRecognitionResult, result.isFinal  else {
                            return
                        }
                        for alternative in result.alternativesArray {
                            guard let alternative = alternative as? SpeechRecognitionAlternative else {
                                return
                            }
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

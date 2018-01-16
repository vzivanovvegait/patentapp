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

struct Word {
    var mainString:String
    var isSpecial:Bool
    var isFound:Bool
}

final class StoryViewController: UIViewController, StoryboardInitializable {
    
    var audioData: NSMutableData!
    
    @IBOutlet weak var startButton: RecordStopButton!
    @IBOutlet weak var hintButton: HintButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
//    var aString:String! = "once upon a time, there was a king, who had 12 daughters - 12 princesses."
//    var image:UIImage!
    
    var arrayOfWords = [Word]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.delegate = self
        imageView.image = UIImage(named: "1")
        
        hintButton.setImage(#imageLiteral(resourceName: "hint").withRenderingMode(.alwaysTemplate), for: .normal)
        
        AudioController.sharedInstance.delegate = self
        
        arrayOfWords = DataUtils.getDataArray()
        
        label.text = StringUtils.createString(from: arrayOfWords)
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
    
    @IBAction func hintNumberAction(_ sender: HintButton) {
        
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
                            
                            strongSelf.label.text = strongSelf.makeString(arrayOfStrings: arrayOfString)
                            
                            if let s = StringUtils.checkIsFinish(wordArray: strongSelf.arrayOfWords) {
                                strongSelf.label.text = s
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func makeString(arrayOfStrings: [String]) -> String {
        var foundWords = [String]()
        
        for index in 0..<arrayOfWords.count {
            if !arrayOfWords[index].isSpecial {
                if arrayOfWords[index].isFound {
                    foundWords.append(arrayOfWords[index].mainString)
                } else if checkString(word: arrayOfWords[index].mainString, in: arrayOfStrings) {
                    arrayOfWords[index].isFound = true
                    foundWords.append(arrayOfWords[index].mainString)
                } else {
                    foundWords.append(replaceString(word: arrayOfWords[index].mainString, with: "_"))
                }
            } else {
//                foundWords.append(arrayOfWords[index].mainString)
            }
        }
        
        return foundWords.joined(separator: " ").replacingOccurrences(of: " ,", with: ",", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: " .", with: ".", options: NSString.CompareOptions.literal, range: nil)
    }
    
    func stop() {
        if AudioController.sharedInstance.remoteIOUnit != nil {
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }
    }
    
    func checkString(word: String, in array: [String]) -> Bool {
        return array.contains(where: { $0.uppercased() == word.uppercased() }) ? true : false
    }
    
    func replaceString(word: String, with: String) -> String {
        return String(word.map {_ in
            return "_"
        })
    }
    
}

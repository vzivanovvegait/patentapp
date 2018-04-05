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
import AudioToolbox

let SAMPLE_RATE = 16000

final class StoryViewController: UIViewController, StoryboardInitializable, KeyboardHandlerProtocol {
    
    var pageController = UIPageViewController()
    var viewControllers = [StoryPartViewController]()
    
    var audioData: NSMutableData!
    
    @IBOutlet weak var topToolBar: TopToolBar!
    @IBOutlet weak var bottomToolBar: BottomToolBar!
    @IBOutlet weak var sendContainerView: SendContainerView!
    @IBOutlet weak var storyPartContainerView: UIView!
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    var parts = NSOrderedSet()
    
    var storyIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
        setContainerView()
        setTopBar()
        setBottomBar()
        setSendContainer()
        
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Set data
    
    func setData() {
        for (index, part) in parts.enumerated() {
            if part is DBStoryPart {
                let vc:StoryPartViewController = StoryPartViewController.makeFromStoryboard()
                vc.setStoryPart(storyPart: part as! DBStoryPart)
                vc.index = index
                viewControllers.append(vc)
            }
        }
    }
    
    // Set UI
    
    func setContainerView() {
        
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([viewControllers.first!], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pageController)
        pageController.view.frame = storyPartContainerView.bounds
        storyPartContainerView.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
    }
    
    func save() -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func setTopBar() {
        
        topToolBar.backAction = {
            self.stop()
            
            DialogUtils.showYesNoDialog(self, title: nil, message: "Do you want to save the progress?", completion: { (result) in
                if result {
                    let _ = self.save()
                }
                self.navigationController?.popViewController(animated: true)
            })
            
        }
        
        topToolBar.restartAction = {
            DialogUtils.showMoreDialog(self, title: nil, message: nil, choises: ["Start Over This Page", "Start Over Entire Story"], completion: { (result) in
                if result == "Start Over This Page" {
                    (self.parts[self.storyIndex] as! DBStoryPart).reset()
                    self.viewControllers[self.storyIndex].setTextLabel()
                } else if result == "Start Over Entire Story" {
                    for part in self.parts {
                        (part as! DBStoryPart).reset()
                    }
                    self.viewControllers[self.storyIndex].setTextLabel()
                }
            })
        }
    }

    func setBottomBar() {
        
        bottomToolBar.notesAction = {
            let navigationController = NotesViewController.makeFromStoryboard().embedInNavigationController()
            self.present(navigationController, animated: true, completion: nil)
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
            DialogUtils.showMultipleChoiceActionSheet(self, anchor: self.view, title: nil, message: nil, choises: ["Level", "Font"], completion: { (result) in
                if result == "Level" {
                    self.viewControllers[self.storyIndex].showLevel()
                }
                
                if result == "Font" {
                    self.showFontParametar().delegate = self
                }
            })
        }
        
        bottomToolBar.infoAction = {
            let vc = InfoViewController.makeFromStoryboard()
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func setSendContainer() {
        sendContainerView.registerView { (text) in
            if self.viewControllers[self.storyIndex].checkStringFromResponse(response: text) {
                self.sendContainerView.removeFirstResponder()
                self.viewControllers[self.storyIndex].setTextLabel()
            } else {
                self.playAudio()
            }
        }
    }
    
    var player: AVAudioPlayer?
    
    func playAudio() {
        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryAmbient)
//        } catch { }
        
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
    
    // Play/Stop actions
    
    func play() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryRecord)
//        } catch { }
        
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
                            strongSelf.bottomToolBar.setGoogleSpeechLabel(text: alternative.transcript)
                            if /*result.isFinal &&*/ strongSelf.viewControllers[strongSelf.storyIndex].checkStringFromResponse(response: alternative.transcript) {
                                strongSelf.viewControllers[strongSelf.storyIndex].setTextLabel()
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }

}

extension StoryViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.index(of: viewController as! StoryPartViewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard viewControllers.count > previousIndex else {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.index(of: viewController as! StoryPartViewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        guard let index = (pageViewController.viewControllers?.first as? StoryPartViewController)?.index else { return }
        storyIndex = index
        print(index)
    }
    
}

extension StoryViewController: SettingsDelegate {
    func changeFont(fontSize: CGFloat) {
        UserDefaults.standard.set(Int(fontSize), forKey: "fontSize")
        viewControllers[storyIndex].setTextLabel()
        print(fontSize)
    }
}


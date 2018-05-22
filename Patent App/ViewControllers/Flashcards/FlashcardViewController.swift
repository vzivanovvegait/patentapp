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

class Element {
    var text: String = ""
    var isSpecial: Bool = false
    var isFound = false
}

final class FlashcardViewController: UIViewController, StoryboardInitializable, KeyboardHandlerProtocol {
    
    var pageController = UIPageViewController()
    var viewControllers = [FlashcardPartViewController]()
    
    @IBOutlet weak var topToolBar: TopToolBar!
    @IBOutlet weak var bottomToolBar: BottomToolBar!
    @IBOutlet weak var sendContainerView: SendContainerView!
    @IBOutlet weak var sendboxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    var flashcards = [Flashcard]()
    
    var image:UIImage?
    var question: String?
    var answer: String = ""
    
    var storyIndex = 0
    
    var audioData: NSMutableData = NSMutableData()
    
    var player: AVAudioPlayer?
    
    var strictOrder: Bool = false
    
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // Set data
    
    func setData() {
        for (index, flashcard) in flashcards.enumerated() {
            let vc:FlashcardPartViewController = FlashcardPartViewController.makeFromStoryboard()
            vc.index = index
            if let data = flashcard.imageData as Data?, let image = UIImage(data: data) {
                vc.image = image
            } else {
                vc.question = flashcard.question
            }
            vc.answer = flashcard.answer
            vc.delegate = self
            viewControllers.append(vc)
        }
    }
    
    // Set UI
    
    func setContainerView() {
        
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([viewControllers.first!], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pageController)
        pageController.view.frame = containerView.bounds
        containerView.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
    }
    
    func setSendContainer() {
        sendContainerView.registerView { [weak self] (text) in
            
            guard let strongSelf = self else {
                return
            }
            if strongSelf.viewControllers[strongSelf.storyIndex].checkString(googleString: text) {
                strongSelf.sendContainerView.removeFirstResponder()
            } else {
               strongSelf.playAudio()
            }
        }
    }
    
    func setTopBar() {
        
        topToolBar.backAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.stop()
            if strongSelf.bottomToolBar.recordButton.isSelected {
                strongSelf.bottomToolBar.recordButton.isSelected = false
            }
            strongSelf.navigationController?.popViewController(animated: true)
        }
        
        topToolBar.restartAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            DialogUtils.showYesNoDialog(strongSelf, title: nil, message: "Start over this practice session?", completion: { (result) in
                if result {
                    strongSelf.viewControllers[strongSelf.storyIndex].resetFlashcard()
                }
            })
        }
    }
    
    func setBottomBar() {
        
        bottomToolBar.notesButton.isHidden = true
        
        bottomToolBar.showAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.viewControllers[strongSelf.storyIndex].showDefinition()
        }
        
        bottomToolBar.keyboardAction = { [weak self] in
            self?.sendContainerView.setFirstResponder()
        }
        
        bottomToolBar.playAction = { [weak self] isPlay in
            if isPlay {
                self?.play()
            } else {
                self?.stop()
            }
        }
        
        bottomToolBar.settingsAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            DialogUtils.showMultipleChoiceActionSheet(strongSelf, anchor: strongSelf.view, title: nil, message: nil, choises: ["Strict Order", "Level", "Font"], completion: { (result) in
                
                if result == "Strict Order" {
                    DialogUtils.showYesNoDialog(strongSelf, title: nil, message: "Turn \(strongSelf.strictOrder ? "off" : "on") strict order?", completion: { (result) in
                        if result {
                            strongSelf.strictOrder = !strongSelf.strictOrder
                            
                            for vc in strongSelf.viewControllers {
                                vc.strictOrder = strongSelf.strictOrder
                            }
                        }
                    })
                }
                
                if result == "Level" {
                    strongSelf.viewControllers[strongSelf.storyIndex].showLevel()
                }
                
                if result == "Font" {
                    strongSelf.showFontParametar().delegate = self
                }
            })
        }
        
        bottomToolBar.infoButton.isHidden = true
        
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
    
    func playAudio() {
        
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
    
    @objc func appMovedToBackground() {
        save()
    }
    
    func save() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
        }
        
        if bottomToolBar.recordButton.isSelected {
            bottomToolBar.recordButton.isSelected = false
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
                            let _ = strongSelf.viewControllers[strongSelf.storyIndex].checkString(googleString: alternative.transcript)
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
}

extension FlashcardViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.index(of: viewController as! FlashcardPartViewController) else {
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
        
        guard let viewControllerIndex = viewControllers.index(of: viewController as! FlashcardPartViewController) else {
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

        guard let controller = pageViewController.viewControllers?.first as? FlashcardPartViewController, let index = controller.index else { return }
        storyIndex = index
    }
    
}

extension FlashcardViewController: FlashcardPartDelegate {
    func timer(isValid: Bool, time: Int) {
        topToolBar.timerLabel.isHidden = !isValid
        topToolBar.timerLabel.text = "\(time)"
    }
    
    func pageSolved() {
        stop()
        if bottomToolBar.recordButton.isSelected {
            bottomToolBar.recordButton.isSelected = false
        }
    }
    
}

extension FlashcardViewController: SettingsDelegate {
    func changeFont(fontSize: CGFloat) {
        UserDefaults.standard.set(Int(fontSize), forKey: "fontSize")
        viewControllers[storyIndex].increaseFont()
    }
}

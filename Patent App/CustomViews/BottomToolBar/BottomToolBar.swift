//
//  BottomToolBar.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/1/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class BottomToolBar: UIView {
    
    var notesAction: (()->())?
    var previousAction: (()->())?
    var nextAction: (()->())?
    var keyboardAction: (()->())?
    var playAction:((Bool)->())?
    
    @IBOutlet weak var startButton: RecordStopButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        setupViews()
    }
    
    // MARK: - Setup
    
    fileprivate func xibSetup() {
        let nib = UINib(nibName: "BottomToolBar", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    fileprivate func setupViews() {
        keyboardButton.isEnabled = false
        keyboardButton.setImage(#imageLiteral(resourceName: "ic_keyboard").withRenderingMode(.alwaysTemplate), for: .normal)
        keyboardButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        startButton.delegate = self
        notesButton.setImage(#imageLiteral(resourceName: "note").withRenderingMode(.alwaysTemplate), for: .normal)
        notesButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        backButton.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        forwardButton.setImage(#imageLiteral(resourceName: "forward").withRenderingMode(.alwaysTemplate), for: .normal)
        forwardButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        backButton.isEnabled = false
        forwardButton.isEnabled = true
    }
    
    // Actions
    
    @IBAction func notes(_ sender: Any) {
        notesAction?()
    }
    
    @IBAction func previous(_ sender: Any) {
        previousAction?()
    }
    
    @IBAction func next(_ sender: Any) {
        nextAction?()
    }

    @IBAction func keyboard(_ sender: Any) {
        keyboardAction?()
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        startButton.isSelected = !startButton.isSelected
        if (startButton.isSelected) {
            playAction?(true)
            keyboardButton.isEnabled = true
        } else {
            playAction?(false)
            keyboardButton.isEnabled = false
        }
    }
    
    func setupPrevNextButtons (index: Int, in arrayCount: Int) {
        backButton.isEnabled = true
        forwardButton.isEnabled = true
        if (index == 0) {
            backButton.isEnabled = false
        }
        if (index == arrayCount - 1) {
            forwardButton.isEnabled = false
        }
    }
}

extension BottomToolBar: RecordStopButtonDelegate {
    func timeExpired() {
//        stop()
    }
}

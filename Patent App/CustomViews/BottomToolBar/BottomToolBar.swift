//
//  BottomToolBar.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/1/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class BottomToolBar: UIView {
    
    var timer = Timer()
    
    var notesAction: (()->())?
    var keyboardAction: (()->())?
    var playAction:((Bool)->())?
    var settingsAction:(()->())?
    var infoAction:(()->())?
    
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var googleSpeechLabel: UILabel!
    
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
        googleSpeechLabel.text = ""
        
        keyboardButton.setImage(#imageLiteral(resourceName: "ic_keyboard").withRenderingMode(.alwaysTemplate), for: .normal)
        keyboardButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        notesButton.setImage(#imageLiteral(resourceName: "note").withRenderingMode(.alwaysTemplate), for: .normal)
        notesButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        settingsButton.setImage(#imageLiteral(resourceName: "gearwheel").withRenderingMode(.alwaysTemplate), for: .normal)
        settingsButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        infoButton.setImage(#imageLiteral(resourceName: "info-icon").withRenderingMode(.alwaysTemplate), for: .normal)
        infoButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        setupRecordButton()
    }
    
    func setupRecordButton() {
        
        recordButton.startAction = {
            self.playAction?(true)
        }
        
        recordButton.stopAction = {
            self.playAction?(false)
        }
    }
    
    // Actions
    
    @IBAction func notes(_ sender: Any) {
        notesAction?()
    }

    @IBAction func keyboard(_ sender: Any) {
        keyboardAction?()
    }
    
    @IBAction func settings(_ sender: Any) {
        settingsAction?()
    }
    
    func setGoogleSpeechLabel(text: String){
//        googleSpeechLabel.isHidden = false
        googleSpeechLabel.text = text
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(counter), userInfo: nil, repeats: false)
    }
    
    @IBAction func infoAction(_ sender: Any) {
        infoAction?()
    }
    
    @objc func counter() {
        UIView.transition(with: googleSpeechLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.googleSpeechLabel.text = ""
        }, completion: nil)
    }
}

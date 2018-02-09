//
//  RecordButton.swift
//  aaaaaa
//
//  Created by Vladimir Zivanov on 2/9/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class RecordButton: UIButton {
    
    var startAction: (()->())?
    var stopAction: (()->())?
    
    var ovalLayer = CAShapeLayer()
    
    var ovalPathStart: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: self.frame.width/2)
    }
    
    var ovalPathEnd: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: self.frame.width + 10, height: self.frame.height + 10), cornerRadius: (self.frame.width + 10)/2)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        self.tintColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
        
        ovalLayer.fillColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        ovalLayer.path = ovalPathStart.cgPath
        self.layer.addSublayer(ovalLayer)
        
    }
    
    func changeToBigger() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathStart.cgPath
        expandAnimation.toValue = ovalPathEnd.cgPath
        expandAnimation.duration = 0.1
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        ovalLayer.add(expandAnimation, forKey: nil)
    }
    
    func changeToSmaller() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathEnd.cgPath
        expandAnimation.toValue = ovalPathStart.cgPath
        expandAnimation.duration = 0.1
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        ovalLayer.add(expandAnimation, forKey: nil)
    }
    
    @objc func touchDown() {
//        setSession()
        changeToBigger()
        AudioServicesPlaySystemSound(1519)
//        AudioServicesPlaySystemSound(1114)
        startAction?()
    }
    
    @objc func touchUpInside() {
//        setSession()
        stopAction?()
        changeToSmaller()
        AudioServicesPlaySystemSound(1519)
//        AudioServicesPlaySystemSound(1114)
    }
    
    @objc func touchDragExit() {
        stopAction?()
//        setSession()
        changeToSmaller()
        AudioServicesPlaySystemSound(1519)
//        AudioServicesPlaySystemSound(1114)
    }
    
//    func setSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryAmbient)
//        } catch { }
//    }

}

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
    
    override var isSelected: Bool {
        didSet {
            if !isSelected {
                stopAction?()
                ovalLayer.fillColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
                changeToSmaller()
            }
        }
    }
    
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
        
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        ovalLayer.fillColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        ovalLayer.path = ovalPathStart.cgPath
        self.layer.insertSublayer(ovalLayer, at: 0)
        self.setImage(#imageLiteral(resourceName: "microphone_white"), for: .normal)
        self.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        if let imageView = self.imageView {
            self.bringSubview(toFront: imageView)
        }
        
    }
    
    func changeToBigger() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathStart.cgPath
        expandAnimation.toValue = ovalPathEnd.cgPath
        expandAnimation.duration = 0.2
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        
//        let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
//        colourAnim.fromValue = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
//        colourAnim.toValue = UIColor(red: 1, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
//        colourAnim.duration = 0.2
        
//        let colorAndScale = CAAnimationGroup()
//        colorAndScale.animations = [ colourAnim]
//        colorAndScale.duration = 0.2
//        colorAndScale.isRemovedOnCompletion = false
        
        ovalLayer.add(expandAnimation, forKey: nil)
    }
    
    func changeToSmaller() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathEnd.cgPath
        expandAnimation.toValue = ovalPathStart.cgPath
        expandAnimation.duration = 0.2
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        ovalLayer.add(expandAnimation, forKey: nil)
    }
    
    @objc func touchUpInside() {
        
        AudioServicesPlaySystemSound(1519)
        if isSelected {
            stopAction?()
            ovalLayer.fillColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
            changeToSmaller()
        } else {
            self.startAction?()
            ovalLayer.fillColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).cgColor
            changeToBigger()
        }
        isSelected = !isSelected
    }
    
}

//
//  RecordStopButton.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/5/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class RecordStopButton: UIButton {
    
    var ovalLayer = CAShapeLayer()
    
    var ovalPath: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 8.0, y: 8.0, width: self.frame.width - 16, height: self.frame.height - 16), cornerRadius: (self.frame.width - 16)/2)
    }
    
    var rectPath: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 20.0, y: 20.0, width: self.frame.width - 40, height: self.frame.height - 40), cornerRadius: 3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                self.changeFromOvalToRect()
            } else {
                self.changeFromRectToOval()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
    func setupView() {
        self.tintColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 5
        
        ovalLayer.fillColor = UIColor.red.cgColor
        ovalLayer.path = ovalPath.cgPath
        self.layer.addSublayer(ovalLayer)
    }
    
    func changeFromOvalToRect() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPath.cgPath
        expandAnimation.toValue = rectPath.cgPath
        expandAnimation.duration = 0.1
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        ovalLayer.add(expandAnimation, forKey: nil)
    }
    
    func changeFromRectToOval() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = rectPath.cgPath
        expandAnimation.toValue = ovalPath.cgPath
        expandAnimation.duration = 0.1
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        ovalLayer.add(expandAnimation, forKey: nil)
    }
    

}

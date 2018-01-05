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
        return UIBezierPath(roundedRect: CGRect(x: 10.0, y: 10.0, width: self.frame.width - 20, height: self.frame.height - 20), cornerRadius: (self.frame.width - 20)/2)
    }
    
    var rectPath: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 18.0, y: 18.0, width: self.frame.width - 36, height: self.frame.height - 36), cornerRadius: 3)
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
        self.layer.borderWidth = 4
        
        ovalLayer.fillColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
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

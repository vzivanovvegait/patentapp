//
//  RecordStopButton.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/5/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

protocol RecordStopButtonDelegate: class {
    func timeExpired()
}

class RecordStopButton: UIButton {
    
    weak var delegate:RecordStopButtonDelegate?
    
    var timer = Timer()
    var count:CGFloat = 0 {
        didSet {
            circlePathLayer.strokeEnd = 0.0
        }
    }
    
    var ovalLayer = CAShapeLayer()
    let circlePathLayer = CAShapeLayer()
    let backgroundCirclePathLayer = CAShapeLayer()
    
    var ovalPath: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 10.0, y: 10.0, width: self.frame.width - 20, height: self.frame.height - 20), cornerRadius: (self.frame.width - 20)/2)
    }
    
    var rectPath: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 18.0, y: 18.0, width: self.frame.width - 36, height: self.frame.height - 36), cornerRadius: 3)
    }
    
    var circlePath: UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.width / 2.0), radius: (frame.size.width - 8)/2, startAngle: -CGFloat(Double.pi) / 2, endAngle:  3 * CGFloat(Double.pi) / 2, clockwise: true)
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
//                self.startTimer()
            } else {
                self.changeFromRectToOval()
//                stopTimer()
            }
        }
    }
    
    func setupView() {
        self.tintColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        backgroundCirclePathLayer.lineWidth = 4
        backgroundCirclePathLayer.fillColor = UIColor.clear.cgColor
        backgroundCirclePathLayer.strokeColor = UIColor.white.cgColor
        backgroundCirclePathLayer.path = circlePath.cgPath
        layer.addSublayer(backgroundCirclePathLayer)
        
        circlePathLayer.frame = self.layer.bounds
        circlePathLayer.lineWidth = 4
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        circlePathLayer.lineCap = kCALineCapRound
        circlePathLayer.path = circlePath.cgPath
        circlePathLayer.strokeEnd = 0.0
        layer.addSublayer(circlePathLayer)
        
        
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
    
    func startTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
        
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func counter() {
        
        count += 0.1/240.0
        
        circlePathLayer.strokeEnd = CGFloat(count)
        
        if count >= 1.0 {
            self.isEnabled = false
            self.isSelected = false
            self.delegate?.timeExpired()
        }
        
    }
    

}

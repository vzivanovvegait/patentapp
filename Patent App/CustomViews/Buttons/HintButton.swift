//
//  HintButton.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/9/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class HintButton: UIButton {

    var badgeLabel = UILabel()
    
    let borderLayer = CAShapeLayer()
    
    var badge: Int? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }
    
    @IBInspectable public var badgeBackgroundColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1) {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    @IBInspectable public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    @IBInspectable public var badgeFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButon(badge: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToButon(badge: nil)
    }
    
    func addBadgeToButon(badge: Int?) {
        self.tintColor = badgeBackgroundColor
        if let badge = badge {
            badgeLabel.text = "\(badge)"
        }
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        let badgeSize = badgeLabel.frame.size
        
        let height = max(18, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        let x = self.frame.width - CGFloat(width)
        let y = CGFloat(10)
        badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
        
        self.makeBorderWithCornerRadius(radius: badgeLabel.frame.height/2, borderColor: UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1), borderWidth: 2)
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }
    
    func makeBorderWithCornerRadius(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let rect = badgeLabel.bounds
        
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the shape layer and set its path
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path  = maskPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        badgeLabel.layer.mask = maskLayer
        
        //Create path for border
        let borderPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the shape layer and set its path
        
        
        borderLayer.frame       = rect
        borderLayer.path        = borderPath.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor   = UIColor.clear.cgColor
        borderLayer.lineWidth   = borderWidth
        
        //Add this layer to give border.
        badgeLabel.layer.addSublayer(borderLayer)
    }

}

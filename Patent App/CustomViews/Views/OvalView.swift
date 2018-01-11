//
//  OvalView.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/10/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class OvalView: UIButton {
    
    var hintLabel = UILabel()
    
    var text:String? {
        didSet {
            hintLabel.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func draw(_ rect: CGRect) {
        let ellipsePath = UIBezierPath(ovalIn: self.bounds)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ellipsePath.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        shapeLayer.lineWidth = 2.0

        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    func setupView() {
        self.backgroundColor? = UIColor.clear
        addLabel()
    }
    
    func addLabel() {
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        hintLabel.font = UIFont(name: "Chalkduster", size: 15)
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0
        self.addSubview(hintLabel)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[label]-10-|",
                                                           options: NSLayoutFormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["label": hintLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label]-10-|",
                                                           options: NSLayoutFormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["label": hintLabel]))
    }

}

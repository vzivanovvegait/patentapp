//
//  FlashcardSetTableViewCell.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 5/22/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class FlashcardSetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flashcardSetNameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        shareButton.setImage(#imageLiteral(resourceName: "share").withRenderingMode(.alwaysTemplate), for: .normal)
        shareButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
    }
    
}

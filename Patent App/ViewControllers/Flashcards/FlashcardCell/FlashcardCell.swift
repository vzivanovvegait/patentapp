//
//  FlashcardCell.swift
//  Patent App
//
//  Created by Marko Stajic on 5/16/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class FlashcardCell: UITableViewCell {

    @IBOutlet weak var flashcardNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var checkmarkImageView: UIImageView!

    var buttonActionFlashcardAction: ((Flashcard, Bool)->())?
    
    var flashcard: Flashcard! {
        didSet {
            if flashcard.isSelected {
                checkmarkImageView.image = #imageLiteral(resourceName: "ic_full_checkmark").withRenderingMode(.alwaysTemplate)
            } else {
                checkmarkImageView.image = #imageLiteral(resourceName: "ic_empty_checkmark").withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        flashcardNameLabel.font = UIFont.systemFont(ofSize: 20)
        flashcardNameLabel.textColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
        checkmarkImageView.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        self.buttonActionFlashcardAction?(self.flashcard, false)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        self.buttonActionFlashcardAction?(self.flashcard, true)
    }
    
}

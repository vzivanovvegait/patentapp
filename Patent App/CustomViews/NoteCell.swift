//
//  NoteCell.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/26/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
   

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

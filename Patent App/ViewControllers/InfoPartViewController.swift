//
//  InfoPartViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/14/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class InfoPartViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var index:Int!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image

        // Do any additional setup after loading the view.
    }

}

extension InfoPartViewController: StoryboardInitializable {
    
}

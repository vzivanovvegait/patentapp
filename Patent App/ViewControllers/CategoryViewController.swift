//
//  CategoryViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/11/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import Crashlytics

final class CategoryViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var testLabel: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func flashcards(_ sender: Any) {
        let flashcardSetListViewController = FlashcardSetsViewController.makeFromStoryboard()
        self.navigationController?.pushViewController(flashcardSetListViewController, animated: true)
    }
    
    @IBAction func story(_ sender: Any) {
        let listViewController = ListViewController.makeFromStoryboard()
        self.navigationController?.pushViewController(listViewController, animated: true)
    }
}

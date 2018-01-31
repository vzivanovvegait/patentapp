//
//  NotesViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/26/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class NotesViewController: UIViewController {
    
    var notes = [Note]()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    
        self.notes = NoteController.shared.getNotes()
        
        tableView.tableFooterView = UIView()
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem = barButtonItem
        // Do any additional setup after loading the view.
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        cell.wordLabel.text = notes[indexPath.row].word
        cell.explanationLabel.text = notes[indexPath.row].explanation
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete \(notes[indexPath.row].word!) from notes?", completion: { (result) in
                if result {
                    if NoteController.shared.deleteNote(note: self.notes[indexPath.row]) {
                        DialogUtils.showWarningDialog(self, title: nil, message: "Note has been successfully deleted!", completion: nil)
                        self.notes.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        DialogUtils.showWarningDialog(self, title: nil, message: "Error!!!", completion: nil)
                    }
                }
            })
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

extension NotesViewController: StoryboardInitializable {
    
}

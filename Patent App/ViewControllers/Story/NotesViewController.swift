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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DialogUtils.showYesNoDialogWithInput(self, title: "Update note", message: nil, positive: "Save", cancel: "Cancel", completion: { (success, text) in
            if success {
                self.notes[indexPath.row].explanation = text
                if NoteController.shared.saveNote() {
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                } else {
                    DialogUtils.showWarningDialog(self, title: nil, message: "Error!!!", completion: nil)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
//        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
//            DialogUtils.showYesNoDialogWithInput(self, title: "Update note", message: nil, positive: "Save", cancel: "Cancel", completion: { (success, text) in
//                if success {
//                    self.notes[indexPath.row].explanation = text
//                    if NoteController.shared.saveNote() {
//                        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
//                    } else {
//                        DialogUtils.showWarningDialog(self, title: nil, message: "Error!!!", completion: nil)
//                    }
//                }
//            })
//        })
//        editAction.backgroundColor = UIColor.blue
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            DialogUtils.showYesNoDialog(self, title: "Delete", message: "Are you sure you want to delete \(self.notes[indexPath.row].word!) from notes?", completion: { (result) in
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
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
}

extension NotesViewController: StoryboardInitializable {
    
}

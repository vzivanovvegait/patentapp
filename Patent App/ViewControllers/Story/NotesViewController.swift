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
    
    var visibleRect = CGRect.zero
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    
        self.notes = NoteController.shared.getNotes()
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem = barButtonItem
        // Do any additional setup after loading the view.
        
        registerKeyboardNotifications()
    }
    
    @objc func close() {
        
        let _ = NoteController.shared.saveNote()
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
        cell.explanationTextView.text = notes[indexPath.row].explanation
        cell.explanationTextView.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension NotesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        notes[textView.tag].explanation = textView.text
        
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        let rect = textView.convert(textView.bounds, to: tableView)
        let bottomInputViewPoint = CGPoint(x: 0, y: rect.maxY + 30)
        
        if !visibleRect.contains(bottomInputViewPoint) {
            let indexPath = IndexPath(row: textView.tag, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }
        return true
    }
}

extension NotesViewController: StoryboardInitializable {
    
}

fileprivate extension NotesViewController {
    
    fileprivate func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyBoardValueBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyBoardValueEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, keyBoardValueBegin != keyBoardValueEnd else {
                return
        }
        
        let keyboardHeight = keyBoardValueEnd.height
        
        tableView.contentInset.bottom = keyboardHeight
        
        visibleRect = self.tableView.frame
        visibleRect.size.height -= keyboardHeight
    }
    
    
}

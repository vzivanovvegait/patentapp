//
//  DataUtils.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/16/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class DataUtils {
    
    class func createString(from array:[Word]) -> (NSMutableAttributedString, Bool) {
        let attString = NSMutableAttributedString(string: "")
        var rangeCounter = 0
        for index in 0..<array.count {
            if index != 0 {
                if ![".", ",", ":", "?", "!", "?!"].contains(array[index].mainString) {
                    attString.append(NSMutableAttributedString(string: " "))
                    rangeCounter += 1
                }
            }
            let word = NSMutableAttributedString(string: array[index].getString())
            if [.underlined, .firstLastLetter, .clue].contains(array[index].wordState) {
                word.addAttribute(NSAttributedStringKey.kern, value: 3, range: NSRange(location: 0, length: array[index].mainString.count))
            }
            attString.append(word)
            if !array[index].isSpecial {
                attString.addAttribute(NSAttributedStringKey.link, value: "\(index)", range: NSRange(location: rangeCounter, length: array[index].mainString.count))
            }
            
            rangeCounter += array[index].mainString.count
        }
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: CGFloat((fontSize > 25) ? fontSize : 25)), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        if !array.contains(where: { !$0.isFound }) {
            return (attString, true)
        }
        
        return (attString, false)
    }

}

//
//  DataUtils.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/16/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class DataUtils {

    class func getDataArray() -> [Word] {
        
        var arrayOfWords = [Word]()
        
        arrayOfWords.append(Word(mainString: "Once", isSpecial: false))
        arrayOfWords.append(Word(mainString: "upon", isSpecial: false))
        arrayOfWords.append(Word(mainString: "a", isSpecial: false))
        arrayOfWords.append(Word(mainString: "time", isSpecial: false))
        arrayOfWords.append(Word(mainString: ",", isSpecial: true))
        arrayOfWords.append(Word(mainString: "there", isSpecial: false))
        arrayOfWords.append(Word(mainString: "was", isSpecial: false))
        arrayOfWords.append(Word(mainString: "a", isSpecial: false))
        arrayOfWords.append(Word(mainString: "king", isSpecial: false))
        arrayOfWords.append(Word(mainString: ",", isSpecial: true))
        arrayOfWords.append(Word(mainString: "who", isSpecial: false))
        arrayOfWords.append(Word(mainString: "had", isSpecial: false))
        arrayOfWords.append(Word(mainString: "12", isSpecial: false))
        arrayOfWords.append(Word(mainString: "daughters", isSpecial: false))
        arrayOfWords.append(Word(mainString: "-", isSpecial: true))
        arrayOfWords.append(Word(mainString: "12", isSpecial: false))
        arrayOfWords.append(Word(mainString: "princesses", isSpecial: false))
        arrayOfWords.append(Word(mainString: ".", isSpecial: true))
        
        return arrayOfWords
    }
    
    class func createString(from array:[Word]) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: "")
        var rangeCounter = 0
        for index in 0..<array.count {
            if index != 0 {
                if ![".", ",", ":", "?", "!"].contains(array[index].mainString) {
                    attString.append(NSMutableAttributedString(string: " "))
                    rangeCounter += 1
                }
            }
            attString.append(NSMutableAttributedString(string: array[index].getString()))
            attString.addAttribute(NSAttributedStringKey.link, value: "\(index)", range: NSRange(location: rangeCounter, length: array[index].mainString.count))
            
            rangeCounter += array[index].mainString.count
        }
        
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 34), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        return attString
    }

}

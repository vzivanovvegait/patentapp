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
        
        arrayOfWords.append(Word(mainString: "Once", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "upon", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "a", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "time", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: ",", isSpecial: true, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "there", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "was", isSpecial: false, roots: ["were"], hint: nil))
        arrayOfWords.append(Word(mainString: "a", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "king", isSpecial: false, roots: ["kings"], hint: "A man with a crown is often called..?"))
        arrayOfWords.append(Word(mainString: ",", isSpecial: true, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "who", isSpecial: false, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "had", isSpecial: false, roots: ["has", "have"], hint: nil))
        arrayOfWords.append(Word(mainString: "12", isSpecial: false, roots: ["twelve"], hint: "It's a number…are there things/characters that you see a few of? Let's start counting!"))
        arrayOfWords.append(Word(mainString: "daughters", isSpecial: false, roots: ["daughter"], hint: "A girl to a father is a ..?"))
        arrayOfWords.append(Word(mainString: "-", isSpecial: true, roots: nil, hint: nil))
        arrayOfWords.append(Word(mainString: "12", isSpecial: false, roots: ["twelve"], hint: "It's a number…are there things/characters that you see a few of? Let's start counting!"))
        arrayOfWords.append(Word(mainString: "princesses", isSpecial: false, roots: ["princess"], hint: "A daughter of a king is called..?"))
        arrayOfWords.append(Word(mainString: ".", isSpecial: true, roots: nil, hint: nil))
        
        return arrayOfWords
    }
    
    class func createString(from array:[Word]) -> (NSMutableAttributedString, Bool) {
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
            if !array[index].isFound && (array[index].hint != nil) {
                attString.addAttribute(NSAttributedStringKey.link, value: "\(index)", range: NSRange(location: rangeCounter, length: array[index].mainString.count))
            }
            
            rangeCounter += array[index].mainString.count
        }
        
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 34), range: NSRange(attString.string.startIndex..., in: attString.string))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1), range: NSRange(attString.string.startIndex..., in: attString.string))
        
        if !array.contains(where: { !$0.isFound }) {
            return (attString, true)
        }
        
        return (attString, false)
    }

}

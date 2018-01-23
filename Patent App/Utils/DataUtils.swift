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

}

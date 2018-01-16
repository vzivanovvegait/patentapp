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
        
        arrayOfWords.append(Word(mainString: "Once", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "upon", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "a", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "time", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: ",", isSpecial: true, isFound: true))
        arrayOfWords.append(Word(mainString: "there", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "was", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "a", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "king", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: ",", isSpecial: true, isFound: true))
        arrayOfWords.append(Word(mainString: "who", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "had", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "12", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "daughters", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "-", isSpecial: true, isFound: true))
        arrayOfWords.append(Word(mainString: "12", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: "princesses", isSpecial: false, isFound: false))
        arrayOfWords.append(Word(mainString: ".", isSpecial: true, isFound: true))
        
        return arrayOfWords
    }

}

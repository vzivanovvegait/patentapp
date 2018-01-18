//
//  StringUtils.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/16/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class StringUtils {

    class func createString(from wordArray: [Word]) -> String {
        var newStr = wordArray/*.filter { !$0.isSpecial }*/.map { $0.mainString }.joined(separator: " ")
        newStr = newStr.replacingOccurrences(of: " ,", with: ",", options: NSString.CompareOptions.literal, range: nil)
        newStr = newStr.replacingOccurrences(of: " .", with: ".", options: NSString.CompareOptions.literal, range: nil)
        newStr = newStr.replacingOccurrences(of: " ?", with: "?", options: NSString.CompareOptions.literal, range: nil)
        newStr = newStr.replacingOccurrences(of: " !", with: "!", options: NSString.CompareOptions.literal, range: nil)
        newStr = newStr.replacingOccurrences(of: " :", with: ":", options: NSString.CompareOptions.literal, range: nil)
        let replacedString = String(newStr.map {
            if (($0 >= "a" && $0 <= "z") || ($0 >= "A" && $0 <= "Z") || ($0 >= "0" && $0 <= "9")) {
                return "_"
            } else {
                return $0
            }
        })
        
        return replacedString
    }
    
    class func checkIsFinish(wordArray: [Word]) -> String? {
        if !wordArray.contains(where: { !$0.isFound }) {
            return wordArray.map { $0.mainString }.joined(separator: " ").replacingOccurrences(of: " ,", with: ",", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: " .", with: ".", options: NSString.CompareOptions.literal, range: nil)
        }
        return nil
    }

}

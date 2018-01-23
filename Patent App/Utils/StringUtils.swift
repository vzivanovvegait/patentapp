//
//  StringUtils.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/16/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class StringUtils {
    
    class func checkIsFinish(wordArray: [Word]) -> String? {
        if !wordArray.contains(where: { !$0.isFound }) {
            return wordArray.map { $0.mainString }.joined(separator: " ").replacingOccurrences(of: " ,", with: ",", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: " .", with: ".", options: NSString.CompareOptions.literal, range: nil)
        }
        return nil
    }

}

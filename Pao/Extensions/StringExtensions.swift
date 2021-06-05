//
//  StringExtensions.swift
//  Pao
//
//  Created by Exelia Technologies on 02/07/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

extension String {
    static let empty = "";
    
    var isEmptyOrWhitespace: Bool {
        return self.trim.isEmpty;
    }
    
    var trim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
    }
    
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
    
    func removeExtraCommas() -> String {
        if self.isEmptyOrWhitespace {
            return self;
        }
        return self.replacingOccurrences(of: ",,", with: ",");
        //        var resultString = "";
        //        var previousCharWasComma = false;
        //        var foundNonCommaChar = false;
        //
        //        for charIndex in 0..<self.count {
        //            let char = self[charIndex];
        //
        //            let isComma = (char == ",");
        //
        //            if (isComma && foundNonCommaChar && !previousCharWasComma) {
        //                previousCharWasComma = true;
        //                resultString += String(char);
        //            } else if (!isComma) {
        //                foundNonCommaChar = true;
        //                previousCharWasComma = false;
        //                resultString += String(char);
        //            }
        //        }
        
        //        return resultString;
    }
    
    // REF: https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)];
    }
    
    var capitalizingFirstLetter: String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter
    }
    
    var isValidEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        return self.size(withAttributes: [NSAttributedString.Key.font: font]).width
    }
    
    func regexCheck(regex: String) -> Bool {
        let regexExpression = try! NSRegularExpression(pattern: regex, options: .caseInsensitive)
        return regexExpression.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil;
    }
}

extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
        }
    }
}

//
//  CommentsViewController+ExtensionViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 09/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

// MARK: - Helper functions for tagging

extension CommentsTableViewController {
    
    /// returns any keyword for tags at current index
    ///
    /// - Returns: return keyword for tag if found , else return nil.
    func getTag(from textView: UITextView) -> TagKeyword? {
        guard
            let commentText = textView.text,
            !commentText.isEmpty,
            let cursorIndex = textView.cursorIndex else { return nil }
        
        //Splits string into subString-array
        let keywords = commentText.split(separator: " ")
        
        for keyword in keywords {
            /**
             * Four checks, IF keyword:
             *1. cursor position is in a substring
             *2. starts with character "@"
             *3. has only one instance of "@"
             *4. has atleast one character other than "@"
             */
            guard
                isContains(keyword, cursorIndex: cursorIndex),
                keyword.count > 1,
                keyword.starts(with: "@"),
                keyword.filter({$0 == "@"}).count == 1 else { continue }
            
            return TagKeyword(keyword: String(keyword), indexOffset: keyword.startIndex.utf16Offset(in: commentText))
        }
        
        return nil
    }
    
    /// returns any keyword for tags at current index
    ///
    /// - Returns: return keyword for tag if found , else return nil.
    func getTagForLocalPrediction(from textView: UITextView) -> TagKeyword? {
        guard
            let commentText = textView.text,
            !commentText.isEmpty,
            let cursorIndex = textView.cursorIndex else { return nil }
        
        //Splits string into subString-array
        let keywords = commentText.split(separator: " ");
        
        for keyword in keywords {
            
            //IF cursorIndex falls between the keyword
            guard
                isContains(keyword, cursorIndex: cursorIndex),
                !keyword.isEmpty else { continue }
            
            return TagKeyword(keyword: String(keyword), indexOffset: keyword.startIndex.utf16Offset(in: keyword))
        }
        
        return nil
    }
    
    private func isContains(_ string: Substring, cursorIndex: String.Index) -> Bool {
        return (string.startIndex ... string.endIndex).contains(cursorIndex)
    }
}

private extension UITextView {
    
    var range: NSRange {
        let fromIndex = text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: 0)
        let toIndex = text.unicodeScalars.index(fromIndex, offsetBy: cursorOffset ?? 0)
        return NSRange(fromIndex..<toIndex, in: self.text)
    }
    
    var cursorOffset: Int? {
        guard let range = selectedTextRange else { return nil }
        return offset(from: beginningOfDocument, to: range.start)
    }
    
    var cursorIndex: String.Index? {
        guard let cursorOffset = cursorOffset else { return nil }
        return text.utf16.index(text.startIndex, offsetBy: cursorOffset, limitedBy: text.endIndex)
    }
}

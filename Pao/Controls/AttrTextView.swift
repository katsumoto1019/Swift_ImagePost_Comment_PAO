//
//  AttrrTextView.swift
//  Pao
//
//  Created by Waseem Ahmed on 09/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

public enum wordType{
    case hashtag
    case mention
}

//A custom text view that allows hashtags and @ symbols to be separated from the rest of the text and triggers actions upon selection
 public  class AttrTextView: UITextView {
    var textString: NSString?
    var attrString: NSMutableAttributedString?
    public var callBack: ((String, wordType) -> Void)?
    
    var usernameFont: UIFont?
    var hashTagFont: UIFont?
    var mentionFont: UIFont?
    var defaultFont: UIFont =  UIFont.systemFont(ofSize: 12);

    var usernameColor: UIColor?
    var hashTagColor: UIColor?
    var mentionColor: UIColor?
    var defaultColor: UIColor = UIColor.white
    
    var hashTagsEnabled = true
    var mentionsEnabled = true

    var validUsernames = [String]()
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setText(username:String, text: String, validUsernames: [String], andCallBack callBack: @escaping (String, wordType) -> Void) {
        self.callBack = callBack
        self.validUsernames = validUsernames
        let textValue = "\(username)  \(text)";
        self.attrString = NSMutableAttributedString(string: textValue)
        self.textString = NSString(string: textValue)
        
        // Set initial font attributes for our string
        attrString?.addAttribute(NSAttributedString.Key.font, value: defaultFont, range: NSRange(location: 0, length: (textString?.length)!))
        attrString?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (textString?.length)!))
        
        setUserNameAttribs(username: username);
        
        // Call a custom set Hashtag and Mention Attributes Function
        if hashTagsEnabled {
        setAttrWithName(attrName: "Hashtag", wordPrefix: "#", color: self.hashTagColor ?? defaultColor, text: text, font: self.hashTagFont ?? defaultFont)
        }
        
        if mentionsEnabled {
        setAttrWithName(attrName: "Mention", wordPrefix: "@", color: self.mentionColor ?? self.defaultColor, text: text, font: self.mentionFont ?? self.defaultFont)
        }
        
        // Add tap gesture that calls a function tapRecognized when tapped
        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(tapGesture:)))
        addGestureRecognizer(tapper)
    }
    
    func setUserNameAttribs(username: String) {
        let rangeUsername = NSRange(location: 0, length: username.count);
        attrString?.addAttribute(.foregroundColor, value: self.usernameColor ?? defaultColor, range: rangeUsername)
        attrString?.addAttribute(NSAttributedString.Key(rawValue: "Username"), value: 1, range: rangeUsername)
        attrString?.addAttribute(NSAttributedString.Key(rawValue: "Tapped Word"), value: username, range: rangeUsername)
        attrString?.addAttribute(.font, value: self.usernameFont ?? self.defaultFont, range: rangeUsername)
        
    self.attributedText = attrString
    }
    
     func setAttrWithName(attrName: String, wordPrefix: String, color: UIColor, text: String, font: UIFont) {
        //Words can be separated by either a space or a line break
        let charSet = CharacterSet(charactersIn: " \n")
        let words = text.components(separatedBy: charSet)
        var previousRange = NSRange.init(location: 0, length: 0)
        
        //Filter to check for the # or @ prefix
        for word in words.filter({$0.hasPrefix(wordPrefix)}) {
            //let range = textString!.range(of: word)
           
            let range = textString!.range(of: word, range:  NSRange.init(location: previousRange.upperBound, length: textString!.length - previousRange.upperBound));

            if wordPrefix == "@" {
                if validUsernames.contains(String(word.dropFirst())) {
                    attrString?.addAttribute(.foregroundColor, value: color, range: range)
                    attrString?.addAttribute(NSAttributedString.Key(rawValue: attrName), value: 1, range: range)
                    attrString?.addAttribute(NSAttributedString.Key(rawValue: "Clickable"), value: 1, range: range)
                    attrString?.addAttribute(NSAttributedString.Key(rawValue: "Tapped Word"), value: word.replacingOccurrences(of: wordPrefix, with: ""), range: range)
                    attrString?.addAttribute(.font, value: font, range: range)
                }
            } else {
                attrString?.addAttribute(.foregroundColor, value: color, range: range)
                attrString?.addAttribute(NSAttributedString.Key(rawValue: attrName), value: 1, range: range)
                attrString?.addAttribute(NSAttributedString.Key(rawValue: "Clickable"), value: 1, range: range)
                attrString?.addAttribute(NSAttributedString.Key(rawValue: "Tapped Word"), value: word.replacingOccurrences(of: wordPrefix, with: ""), range: range)
                attrString?.addAttribute(.font, value: font, range: range)
            }
            previousRange = range;
        }
        self.attributedText = attrString
    }
    
   @objc func tapRecognized(tapGesture: UITapGestureRecognizer) {
        var wordString: String?         // The String value of the word to pass into callback function
        var char: NSAttributedString!   //The character the user clicks on. It is non optional because if the user clicks on nothing, char will be a space or " "
        var word: NSAttributedString?   //The word the user clicks on
        var isHashtag: AnyObject?
    var isAtMention: AnyObject?
    var isUserName: AnyObject?

        // Gets the range of the character at the place the user taps
        let point = tapGesture.location(in: self)
        let charPosition = closestPosition(to: point)
    let charRange = tokenizer.rangeEnclosingPosition(charPosition!, with: .character, inDirection: UITextDirection(rawValue: 1))
        
        //Checks if the user has tapped on a character.
        if charRange != nil {
            let location = offset(from: beginningOfDocument, to: charRange!.start)
            let length = offset(from: charRange!.start, to: charRange!.end)
            let attrRange = NSMakeRange(location, length)
            char = attributedText.attributedSubstring(from: attrRange)
            
            //If the user has not clicked on anything, exit the function
            if char.string == " "{
                print("User clicked on nothing")
                return
            }
            let range = NSMakeRange(0, char.length);
            // Checks the character's attribute, if any
            isHashtag = char?.attribute(NSAttributedString.Key("Hashtag"), at: 0, longestEffectiveRange: nil, in: range) as AnyObject?
            isAtMention = char?.attribute(NSAttributedString.Key("Mention"), at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, char!.length)) as AnyObject?
            isUserName = char?.attribute(NSAttributedString.Key("Username"), at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, char!.length)) as AnyObject?

            let attributeValue = char?.attribute(NSAttributedString.Key("Tapped Word"), at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, char!.length)) as AnyObject?

            if let keyword = attributeValue as? String, callBack != nil {
                if isHashtag != nil ||  isAtMention != nil || isUserName != nil {
                    if isAtMention != nil {
                        if (validUsernames.contains(keyword)) {
                            callBack!(keyword, wordType.hashtag)
                        }
                    } else {
                        callBack!(keyword, wordType.hashtag)
                    }
                }
                return;
            }
        }
        
        // Gets the range of the word at the place user taps
    let wordRange = tokenizer.rangeEnclosingPosition(charPosition!, with: .word, inDirection: UITextDirection(rawValue: 1))
        
        /*
         Check if wordRange is nil or not. The wordRange is nil if:
         1. The User clicks on the "#" or "@"
         2. The User has not clicked on anything. We already checked whether or not the user clicks on nothing so 1 is the only possibility
         */
        if wordRange != nil{
            // Get the word. This will not work if the char is "#" or "@" ie, if the user clicked on the # or @ in front of the word
            let wordLocation = offset(from: beginningOfDocument, to: wordRange!.start)
            let wordLength = offset(from: wordRange!.start, to: wordRange!.end)
            let wordAttrRange = NSMakeRange(wordLocation, wordLength)
            word = attributedText.attributedSubstring(from: wordAttrRange)
            wordString = word!.string
        }else{
            /*
             Because the user has clicked on the @ or # in front of the word, word will be nil as
             tokenizer.rangeEnclosingPosition(charPosition!, with: .word, inDirection: 1) does not work with special characters.
             What I am doing here is modifying the x position of the point the user taps the screen. Moving it to the right by about 12 points will move the point where we want to detect for a word, ie to the right of the # or @ symbol and onto the word's text
             */
            var modifiedPoint = point
            modifiedPoint.x += 12
            let modifiedPosition = closestPosition(to: modifiedPoint)
            let modifedWordRange = tokenizer.rangeEnclosingPosition(modifiedPosition!, with: .word, inDirection: UITextDirection(rawValue: 1))
            if modifedWordRange != nil{
                let wordLocation = offset(from: beginningOfDocument, to: modifedWordRange!.start)
                let wordLength = offset(from: modifedWordRange!.start, to: modifedWordRange!.end)
                let wordAttrRange = NSMakeRange(wordLocation, wordLength)
                word = attributedText.attributedSubstring(from: wordAttrRange)
                wordString = word!.string
            }
        }
        
        if let stringToPass = wordString{
            // Runs callback function if word is a Hashtag or Mention
            if isHashtag != nil && callBack != nil {
                callBack!(stringToPass, wordType.hashtag)
            } else if isAtMention != nil && callBack != nil {
                callBack!(stringToPass, wordType.mention)
            }
        }
    }
    
    
}

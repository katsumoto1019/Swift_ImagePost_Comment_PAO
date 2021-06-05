//
//  AboutMeBioTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 05/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AboutMeBioTableViewCell: UITableViewCell {
    @IBOutlet weak var bioTextView: PlaceHolderTextView! {
          didSet {
              bioTextView.keyboardAppearance = .dark
              bioTextView.inputAccessoryView = doneBar()
          }
      }
    
    func doneBar() -> UIToolbar {
        let bar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let done = UIBarButtonItem(title: L10n.Common.done, style: .done, target: self, action: #selector(self.donePressed(barButton:)))
        bar.barStyle = .blackTranslucent
        bar.items = [done]
        bar.sizeToFit()
        return bar
    }
    
    private var bioChanged: ((String) -> Void)?
    var bioChangeEnded: ((String) -> Void)?

    @IBOutlet weak var bioTextViewHeightConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let edgeInsets = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right)
        contentView.frame.inset(by: edgeInsets)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
//        bioTextView = PlaceHolderTextView()
//        var bioTextFrame = contentView.frame
//        bioTextFrame.size.width = bioTextFrame.size.width - 10
//        bioTextFrame.size.height = 60.0
//        bioTextFrame.origin.y = bioTextFrame.origin.y - 5
//        bioTextView.frame = bioTextFrame
//        contentView.addSubview(bioTextView)
        
        styleTextView()
    }
    
    func styleTextView() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05);

        bioTextView.delegate = self
        bioTextView.returnKeyType = .default
        bioTextView.isEditable = true
        bioTextView.autocorrectionType = .yes
        bioTextView.isScrollEnabled = false
                
        bioTextView.placeholder = L10n.AboutMeBioTableViewCell.BioTextView.placeholder
        bioTextView.placeholderFont = UIFont.app.withSize(UIFont.sizes.small)
        bioTextView.placeholderColor = ColorName.placeholder.color
        bioTextView.textColor = ColorName.textWhite.color

        bioTextView.font = UIFont.app
    }
    
    func set(bio: String, bioChanged: @escaping (String) -> Void) {
        bioTextView.text = bio
        self.bioChanged = bioChanged
        
        resizeCellToFitContent(textView: bioTextView, replacementText: bio)
    }
    
    @objc func donePressed(barButton: UIBarButtonItem) {
        bioTextView.resignFirstResponder()
    }
}

extension AboutMeBioTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView){
        //bioTextView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        FirbaseAnalytics.logEvent(.editBio)
        
        //TODO: save text to server
        self.bioChangeEnded?(textView.text)
    }

    
    func textViewDidChange(_ textView: UITextView) {
        bioChanged?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        /* //End editting of textview if return/done button is pressed
        if textView.hasReturnPressed(newText:text) {
            textView.resignFirstResponder();
            return false;
        }
        */
        
        //Note: putitng following line in textViewDidChange() was giving a jankines behaviour, that's why we have put this code here
        resizeCellToFitContent(textView: textView, replacementText: text)
        return true
    }
    
    func resizeCellToFitContent(textView:UITextView, replacementText textEntered: String?){
        
        // Calculate if the text view will change height, then only force
        // the table to update if it does.  Also disable animations to
        // prevent "jankiness".
        
        var minimumHeight: CGFloat =  textView.text.isEmpty ? 60 : 30 // To make space for placeHolder
        if let textEntered = textEntered {
            if textEntered == "" && textView.text.count <= 1 {
                minimumHeight = 60 //height of textview for placeholder
            } else if textEntered != "" {
                minimumHeight = 30
            }
        }
        
        let startHeight = textView.frame.size.height
        var calculatedHeight = textView.sizeThatFits(textView.frame.size).height  //iOS 8+ only
        calculatedHeight = calculatedHeight > minimumHeight ? calculatedHeight : minimumHeight
        
        //Manaually handle when user enters/deletes newline character
        if let textEntered = textEntered {
            if textEntered == "\n" {
                calculatedHeight = calculatedHeight + 22; //when newline is entered
            }
            if let text = textView.text, textEntered == "", text.last == "\n" {
                calculatedHeight = calculatedHeight - 15; //when new line is deleted
            }
        }
        
        if startHeight != calculatedHeight {
            bioTextViewHeightConstraint.constant = calculatedHeight
            
            
            if let tableView = superview as? UITableView {
                UIView.setAnimationsEnabled(false) // Disable animations
                tableView.beginUpdates()
                tableView.endUpdates()
                
//                tableView.performBatchUpdates(nil, completion: nil)
                UIView.setAnimationsEnabled(true)  // Re-enable animations.
            }
        }
    }
}

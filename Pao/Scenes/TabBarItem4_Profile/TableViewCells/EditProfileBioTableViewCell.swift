//
//  EditProfileBioTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 07/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditProfileBioTableViewCell: UITableViewCell {
    
    var bioTextView: UITextView! {
        didSet {
            bioTextView.delegate = self;
            bioTextView.keyboardAppearance = .dark
        }
    }
 
    
    private var bioChanged: ((String) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let edgeInsets = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right)
        contentView.frame.inset(by: edgeInsets)
        
        styleTextView()
    }
    
    func set(bio: String, bioChanged: @escaping (String) -> Void) {
        bioTextView = PlaceHolderTextView()
        var bioTextFrame = contentView.frame
        bioTextFrame.size.width = bioTextFrame.size.width - 10
        bioTextFrame.origin.y = bioTextFrame.origin.y - 5
        bioTextView.frame = bioTextFrame
        contentView.addSubview(bioTextView)
        
        self.bioChanged = bioChanged
        bioTextView.text = bio
    }
    
    func styleTextView() {
        bioTextView.textColor = .white
        bioTextView.font = UIFont.app
    }
}

extension EditProfileBioTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioChanged?(textView.text)
    }
}

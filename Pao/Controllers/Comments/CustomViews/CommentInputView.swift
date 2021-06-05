//
//  CommentInputView.swift
//  Pao
//
//  Created by Waseem Ahmed on 12/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit


class CommentInputView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commentTextView: PlaceHolderTextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var descriptionSubView: UIView!
    @IBOutlet weak var stackView: UIStackView!
/*
    lazy var predictionView: PredictionView = {
    let predictionView = Bundle.main.loadNibNamed( "PredictionView", owner: self, options: nil)?.first as! PredictionView;
        predictionView.callback = { (keyword, mention) in
            if let keyword = keyword, mention.count > 0 {
                self.mention(text: mention, at: keyword.indexOffset!, withKeyword: keyword.keyword!);
            }
        };
    return predictionView;
    }()
    */
    /// Max height of textView
    let maxHeight: CGFloat = 100;
    
    var delegate:CommentInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        comonInit();
        getFollowedPeople();
        self.commentTextView.autocorrectionType = .yes;
    }
    
    func comonInit() {
        setupChildViews();
        checkPostButtonStatus();
    }
    
    func setupChildViews() {
        backgroundColor = ColorName.background.color
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.1);
        descriptionSubView.backgroundColor = UIColor.clear;
        descriptionSubView.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor;
        descriptionSubView.makeCornerRound(cornerRadius: 5);
        descriptionSubView.layer.borderWidth = 0.5;
        
        commentTextView.backgroundColor = UIColor.clear;
        commentTextView.textColor = UIColor.white;
        commentTextView.set(fontSize: UIFont.sizes.verySmall);
        commentTextView.isScrollEnabled = false;
        commentTextView.keyboardAppearance = .dark;
        commentTextView.keyboardType = .twitter;
        commentTextView.returnKeyType = .done;
        commentTextView.delegate = self;
        
        commentTextView.placeholderColor =  ColorName.placeholder.color
        commentTextView.placeholderFont = UIFont.app.withSize(UIFont.sizes.verySmall);
        
        postButton.backgroundColor = UIColor.clear;
        postButton.setTitleColor(UIColor.white, for: .normal);
        postButton.titleLabel?.set(fontSize: UIFont.sizes.verySmall);
        postButton.setTitle(L10n.Common.labelPost, for: .normal);
        postButton.addTarget(self, action: #selector(postComment(view:)), for: .touchUpInside);

        profileImageView.makeCornerRound();
        profileImageView.addGestureRecognizer(UIGestureRecognizer.init(target: self, action: #selector(tapHandler(gesture:))));
        profileImageView.isUserInteractionEnabled = true;
        
        if let profileImageUrl = DataContext.cache.user.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageUrl);
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
    }
    
    func localPrediction(tag: TagKeyword?) {
        //predictionView.tagForPrediction(keyword: tag);
    }
 
    private func checkPostButtonStatus() {
        if let commentText = commentTextView.text, commentText.count > 0 {
            postButton.isEnabled = true;
            postButton.setTitleColor(UIColor.white, for: .normal);
        } else {
            postButton.isEnabled = false;
            postButton.setTitleColor(ColorName.placeholder.color, for: .normal)
        }
    }
    
    @objc private func postComment(view:UIButton) {
        delegate?.commentInputView(view: self, postData: commentTextView.text, button: postButton);
        commentTextView.text = "";
        checkPostButtonStatus();
        resizeHeight();
    }
    
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        if gesture.view == profileImageView {
            delegate?.showProfile();
        }
    }
}

// MARK: - TextView delegate
extension CommentInputView: UITextViewDelegate {
    /*
    func textViewDidBeginEditing(_ textView: UITextView) {
        predictionView.removeFromSuperview();
        stackView.addArrangedSubview(predictionView);
        predictionView.clearPredictions();
        
        for constraint in self.constraints where constraint.firstAttribute == .height {
            constraint.constant = constraint.constant + predictionView.bounds.height;
            break;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        predictionView.removeFromSuperview();
        for constraint in self.constraints where constraint.firstAttribute == .height {
            constraint.constant = constraint.constant - predictionView.bounds.height;
            break;
        }
    }
    */
    func textViewDidChange(_ textView: UITextView) {
        checkPostButtonStatus();
        resizeHeight();

        delegate?.commentInputView(view: self, textChangedIn: textView);
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //End editting of textview if return/done button is pressed
        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines, options: .backwards).location != NSNotFound {
            textView.resignFirstResponder();
            return false;
        }
        return true;
    }
    
    func mention(text: String, at indexOffset: Int, withKeyword keyword: String) {
        if let startPosition = commentTextView.position(from: commentTextView.beginningOfDocument, offset: indexOffset),
            let endPosition = commentTextView.position(from: commentTextView.beginningOfDocument, offset: indexOffset + keyword.count),
            let range = commentTextView.textRange(from: startPosition, to: endPosition){
            commentTextView.replace(range, withText: "@\(text) ");
        }
    }
    
    private func resizeHeight() {
        let textSize = commentTextView.sizeThatFits(CGSize.init(width: commentTextView.contentSize.width, height: CGFloat.greatestFiniteMagnitude));
        
        for constraint in self.constraints where constraint.firstAttribute == .height {
//            constraint.constant = (textSize.height > maxHeight ? maxHeight: textSize.height) + 23 + predictionView.bounds.height //(23 is the sum of margins above/below of textview)
            constraint.constant = (textSize.height > maxHeight ? maxHeight: textSize.height) + 23  //(23 is the sum of margins above/below of textview)
            commentTextView.isScrollEnabled = textSize.height > maxHeight;
        }
    }
}

extension CommentInputView {
    func getFollowedPeople() {
        /*
        App.transporter.get([User].self, for: type(of: FollowingsTableViewController.self) as? AnyClass) { (result) in
            if let users = result {
                self.predictionView.predictions = users.map{$0.username!};
            }
        }*/
    }
}

protocol CommentInputViewDelegate {
    func commentInputView(view: CommentInputView, textChangedIn textView: UITextView)
    func commentInputView(view: CommentInputView, postData text: String, button: UIButton)
    func showProfile()
}

//
//  CommentTableViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentTextView: AttrTextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var comment: Comment?
    
    var repostCallback : ((_ comment: Comment?)->Void)?

    var profileCallback : ((_ user: User)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyStyles();
        profileImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(gesture:))));
        profileImageView.isUserInteractionEnabled = true;
    }
    
    func applyStyles() {
        
        backgroundColor = ColorName.background.color
        selectionStyle = .none;

        profileImageView.makeCornerRound();
        
        timeLabel.set(fontSize: UIFont.sizes.verySmall);
        timeLabel.textColor = ColorName.placeholder.color
        
        commentTextView.isScrollEnabled = false;
        commentTextView.isEditable = false;
        commentTextView.isSelectable = false;
        commentTextView.defaultColor = UIColor.white;
        //commentTextView.mentionColor = ColorName.accent.color
        //commentTextView.hashTagColor = ColorName.accent.color
        commentTextView.usernameColor = ColorName.accent.color
        commentTextView.defaultFont = UIFont.app.withSize(UIFont.sizes.small);
        commentTextView.usernameFont = UIFont.app.withSize(UIFont.sizes.small);
        commentTextView.mentionFont = UIFont.appMedium.withSize(UIFont.sizes.small);

        // override UIAppearance so it doesn't reset text style.
        commentTextView.font = nil;
        commentTextView.textColor = nil;
     
        //removing default padding of textview to allignLeading text with timeLbel.
        commentTextView.textContainerInset = UIEdgeInsets.zero
        commentTextView.textContainer.lineFragmentPadding = 0
    }
    
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        if gesture.view == profileImageView, let user = comment?.user {
            FirbaseAnalytics.logEvent(.clickProfileIcon)

            self.profileCallback?(user);
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(comment: Comment) {
        
        self.comment = comment;
        commentTextView.setText(username: comment.user?.username ?? "  ", text: comment.message ?? "", validUsernames: comment.validUsernames ?? []) { (username, wordtype) in
            FirbaseAnalytics.logEvent(.clickProfileIcon)
            if let profileCallback = self.profileCallback {
                let user = User()
                user.username = username
                profileCallback(user)
            }
        }
        
        if let time = comment.timestamp {
            timeLabel.text = time.timeElapsedString();
        }else{
             timeLabel.text = "";
        }
        
        if let profileImageUrl = comment.user?.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageUrl);
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
        
        if comment is CommentLocal {
            set(forLocalComment: comment as! CommentLocal);
        }else{
            timeLabel.textColor = ColorName.placeholder.color
            timeLabel.isUserInteractionEnabled = false;
        }
    }
    
    private func set(forLocalComment comment: CommentLocal){
        if comment.failed {
            timeLabel.text = comment.failedMessage;
            timeLabel.isUserInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(repostComment(gesture:)));
            timeLabel.addGestureRecognizer(tapGesture);
            timeLabel.isUserInteractionEnabled = true;
            timeLabel.textColor = UIColor.red;

        }else{
            timeLabel.text = comment.postingMessage;
            timeLabel.textColor = ColorName.placeholder.color
            timeLabel.isUserInteractionEnabled = false;
        }
    }
    
    @objc private func repostComment(gesture: UIGestureRecognizer){
        repostCallback?(comment);
    }
}

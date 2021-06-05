//
//  CommentsTableViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 12/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//


typealias EmptyCompletion = () -> Void

import UIKit
import IQKeyboardManagerSwift
import RocketData

class CommentsTableViewController: StyledTableViewController {
    
    // MARK: - Internal properties
    
    var commentCallback: ((_ updatedSpot: Spot)-> Void)?
    
    // MARK: - Private properties
    
    private var spot: Spot!
    private var showingTagSuggestions = false
    private var commentsDataSource: CommentsDataSource!
    private lazy var tagSuggestionsDataSource = TagsDataSource()
    private lazy var commentInputView: CommentInputView = {
        let commentView = Bundle.main.loadNibNamed("CommentInputView", owner: self, options: nil)?.first as! CommentInputView
        commentView.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        commentView.delegate = self
        return commentView
    }()
    
    /// Following two functions are required for accessoryView
    override var inputAccessoryView: UIView? {
        get {
            return commentInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Lifecycle
    
    convenience init(style: UITableView.Style, spot: Spot) {
        self.init(style: style)
        self.spot = spot
        commentsDataSource = CommentsDataSource(spot: spot)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Comments"
        
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        title = L10n.CommentsTableViewController.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = ""
        self.commentInputView.commentTextView.resignFirstResponder()
    }
    
    // MARK: - Private methods
    
    private func initialize() {
        setupTableView()
        
        tagSuggestionsDataSource.callBack = { (tag,user) in
            self.mentionUserInTextview(tag: tag, user: user)
        }
        
        commentsDataSource.reloadTableCallback = {
            self.tableView.reloadData()
        }
        
        commentsDataSource.newCommentCallback = {
            
            self.spot.commentsCount = (self.spot.commentsCount ?? 0) + 1
            let dataProvider = DataProvider<Spot>()
            dataProvider.setData(self.spot)
            self.commentCallback?(self.spot)
        }
        
        commentsDataSource.profileCallback = { (user) in
            if let navController = self.navigationController {
                navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                let viewController = UserProfileViewController(user: user)
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
        
        //IQKeybaordMannager moves screen to up when keyboard is shown.we are disableing this because we are handling it manually.
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentsTableViewController.self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.commentInputView.commentTextView.becomeFirstResponder()
        })
    }
    
    private func setupTableView() {
        tableView.register(CommentTableViewCell.self)
        tableView.register(TagTableViewCell.self)
        
        tableView.backgroundColor = ColorName.background.color
        tableView.keyboardDismissMode = .interactive
        tableView.becomeFirstResponder()
        
        showComments()
    }
    
    private func showComments() {
        showingTagSuggestions = false
        //        activityIndicator.startAnimating()
        
        tableView.separatorColor = UIColor.clear
        
        commentsDataSource.linkWith(tableview: tableView)
        commentsDataSource.loadData(reload: commentsDataSource.downloaded) {
            //            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    private func showTagSuggestions(tag: TagKeyword) {
        showingTagSuggestions = true
        //        activityIndicator.startAnimating()
        
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        tagSuggestionsDataSource.linkWith(tableview: tableView)
        tagSuggestionsDataSource.getTags(forTagKeyword: tag) {
            //            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    private func mentionUserInTextview(tag: TagKeyword?, user: User) {
        guard
            showingTagSuggestions,
            let tag = tag,
            let indexOffset = tag.indexOffset,
            let keyword = tag.keyword,
            let username = user.username else { return }
        commentInputView.mention(text: username, at: indexOffset, withKeyword: keyword)
    }
    
    /// chek either should show auto complete suggestions
    private func extractTag(from textView: UITextView) {
        textView.autocorrectionType = .yes
        if let tag = getTag(from: textView) {
            showTagSuggestions(tag: tag)
            textView.autocorrectionType = .no
        } else if showingTagSuggestions {
            showComments()
        }
        
        commentInputView.localPrediction(tag: getTagForLocalPrediction(from: textView))
    }
    
    // MARK: - UITableViewDelegate implementation
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CommentTableViewCell else { return }
        cell.profileCallback = { (user) in
            if let navController = self.navigationController {
                navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                let viewController = UserProfileViewController(user: user)
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
}

// MARK: - CommentInputViewDelegate
extension CommentsTableViewController: CommentInputViewDelegate {
    
    func commentInputView(view: CommentInputView, textChangedIn textView: UITextView) {
        extractTag(from: textView)
    }
    
    func commentInputView(view: CommentInputView, postData text: String, button: UIButton) {
        guard let id = spot.id else { return }
        showComments()
        
        commentsDataSource.addComment(spotId: id, message: text)
        let row = commentsDataSource.comments.count - 1
        let indexPath = IndexPath(row: row, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
        if tableView.indexPathExists(indexPath: indexPath) {
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }
    
    func showProfile() {
        navigationController?.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
        guard let user = DataContext.cache.user else { return }
        if let navController = navigationController {
            navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
            let viewController = UserProfileViewController(user: user)
            viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
            navController.pushViewController(viewController, animated: true)
        }
    }
}

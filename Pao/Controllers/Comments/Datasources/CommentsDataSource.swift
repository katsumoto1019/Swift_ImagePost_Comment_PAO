//
//  CommentsDataSource.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

import RocketData

class CommentsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Internal properties
    
    var comments = [Comment]()
    var downloaded = false
    var reloadTableCallback: (() -> Void)?
    var profileCallback: ((User) -> Void)?
    var newCommentCallback: (() -> Void)?
    
    // MARK: - Private properties
    
    private let spot: Spot
    private var emailContactService: EmailContactService!
    
    // MARK: - Lifecycle
    
    init(spot: Spot) {
        self.spot = spot
        super.init()
    }
    
    // MARK: - Internal methods
    
    func linkWith(tableview: UITableView) {
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    func addComment(spotId: String, message: String) {
        let comment = CommentLocal(localId: Int(Date().timeIntervalSince1970),  message: message, spotId: spotId)
        comment.user = DataContext.cache.user
        comments.append(comment)
        
        post(comment: comment,completionHandler: {
            self.reloadTableCallback?()
        })
    }
    
    func deleteComment(tableView: UITableView, indexPath: IndexPath) {
        guard let viewController = tableView.viewContainingController() else { return }
        let message = L10n.CommentsDataSource.DeleteComment.message
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: L10n.Common.yes, style: .destructive, handler: { (action) in
            guard let commentId = self.comments[indexPath.row].id else {
                self.comments.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return
            }
            
            self.analyticsSendDeleteCommentEvent()
            
            guard let id = self.spot.id else { return }
            
            App.transporter.delete(Comment.self, pathVars: [id, commentId], completionHandler: { (success) in
                if success == true {
                    self.comments.remove(at: indexPath.item)
                    self.spot.commentsCount = (self.spot.commentsCount! - 1).clamped(min: 0)
                    DataModelManager.sharedInstance.updateModel(self.spot)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    self.analyticsDeleteCommentEvent()
                }
            })
        }))
        
        alertController.addAction(UIAlertAction(title: L10n.Common.no, style: .cancel, handler: nil))
        viewController.present(alertController, animated: true)
    }
    
    // MARK: - UITableViewDataSource implementation
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier) as! CommentTableViewCell
        cell.set(comment: comments[indexPath.row])
        
        cell.repostCallback = { (comment) in
            guard let comment = comment as? CommentLocal else { return }
            comment.failed = false
            self.reloadTableCallback?()
            self.post(comment: comment)
        }
        
        cell.profileCallback = profileCallback
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    // MARK: - UITablewViewDelegate implementation
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: L10n.Common.delete, handler: { (action, indexPath) in
            self.deleteComment(tableView: tableView, indexPath: indexPath)
        })
        
        let reportAction = UITableViewRowAction(style: .destructive, title: L10n.CommentsDataSource.reportActionTitle, handler: { (action, indexPath) in
            
            guard let viewController = tableView.viewContainingController() else { return }
            
            self.emailContactService = EmailContactService(viewController: viewController)
            let message = L10n.CommentsDataSource.message
            let categoryAlert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsSpam, style: .destructive, handler: { (action) in
                guard let id = self.comments[indexPath.row].id else { return }
                self.analyticsSendSpamCommentEvent()
                self.emailContactService.composeEmail(subject: "\(L10n.CommentsDataSource.spamComment): " + id)
            }))
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsInappropriate, style: .destructive, handler: { (action) in
                guard let id = self.comments[indexPath.row].id else { return }
                self.analyticsSendInappropriateCommentEvent()
                self.emailContactService.composeEmail(subject: "\(L10n.CommentsDataSource.inappropriateComment): " + id)
            }))
            
            categoryAlert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
            
            tableView.viewContainingController()?.present(categoryAlert, animated: true)
        })
        
        return comments[indexPath.row].user?.id == DataContext.cache.user.id ? [deleteAction] : [reportAction]
    }
}

extension CommentsDataSource: APIDataSource {
    func loadData(reload: Bool = false, completionHandler: (() -> Void)? = nil) {
        
        if downloaded {
            completionHandler?()
            return
        }
        
        guard let id = spot.id else { return }
        
        let vars = CommentsVars(spotId: id)
        App.transporter.get([Comment].self, pathVars: vars) { (result) in
            self.downloaded = true
            guard let result = result else {return}
            self.comments.removeAll(where: {!($0 is CommentLocal)})
            self.comments.append(contentsOf: result)
            completionHandler?()
        }
    }
    
    // MARK: - Private methods
    
    private func post(comment: CommentLocal, completionHandler: (() -> Void)? = nil) {
        
        guard
            let id = spot.id,
            let message = comment.message else { return }
        
        newCommentCallback?()
        
        analyticsEnterCommentOrTagEvent(comment)
        
        let newComment = Comment.init(spotId: id, message: message)
        App.transporter.post(newComment, returnType: Comment.self) { (result) in
            
            if
                let index = self.comments.firstIndex(where: {($0 is CommentLocal) && ($0 as! CommentLocal).localId == comment.localId}),
                let localComment = self.comments[index] as? CommentLocal {
                
                if let result = result {
                    self.comments[index] = result
                    self.analyticsAddCommentEvent()
                } else {
                    localComment.failed = true
                }
                self.reloadTableCallback?()
            }
            completionHandler?()
        }
    }
    
    // MARK: - Analytics
    
    private func analyticsEnterCommentOrTagEvent(_ comment: CommentLocal) {
        let (category, subCategory) = spot.getCategorySubCategoryNameList()
        let postId = spot.id ?? ""
        let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
        AmplitudeAnalytics.logEvent(.enterComment, group: .spot, properties: properties)
        if comment.message?.contains("@") ?? false {
            let postId = spot.id ?? ""
            let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
            AmplitudeAnalytics.logEvent(.tagComment, group: .spot, properties: properties)
        }
    }
    
    private func analyticsAddCommentEvent() {
        AmplitudeAnalytics.addUserValue(property: .comments, value: 1)
    }
    
    private func analyticsSendDeleteCommentEvent() {
        FirbaseAnalytics.logEvent(.deleteComment)
        AmplitudeAnalytics.logEvent(.deleteComment, group: .spot, properties: ["post ID": spot.id ?? ""])
    }
    
    private func analyticsDeleteCommentEvent() {
        AmplitudeAnalytics.addUserValue(property: .comments, value: -1)
    }
    
    private func analyticsSendSpamCommentEvent() {
        FirbaseAnalytics.logEvent(.commentSpam)
        AmplitudeAnalytics.logEvent(.commentSpam, group: .spot, properties: ["post ID": spot.id ?? ""])
    }
    
    private func analyticsSendInappropriateCommentEvent() {
        FirbaseAnalytics.logEvent(.commentInappropriate)
        AmplitudeAnalytics.logEvent(.commentInappropriate, group: .spot)
    }
}

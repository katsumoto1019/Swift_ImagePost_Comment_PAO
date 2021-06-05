//
//  NestedUploadBoardsCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 19/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class NestedUploadBoardCollectionViewController: UploadBoardCollectionViewController {

    var needUpdateCoverPhoto: (()->())?
    private var parentBoard: Board!
    private lazy var menuButton: UIButton = UIButton()

    init(userId: String, parentBoard: Board, generalId: String) {
        super.init(userId: userId);
        self.parentBoard = parentBoard
        self.generalBoardId = generalId
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func getPayloads(completionHandler: @escaping ([Board]?) -> Void) -> PayloadTask? {
        let params = BoardsParams(skip: collection.count, take: collection.bufferSize, userId: userId, keyword: searchString);
        let vars = BoardsVars(boardId: parentBoard.id ?? "");

        if userId == DataContext.cache.user.id, generalBoardId == parentBoard.id {
            setRightBarButtonItem()
        }

        return App.transporter.get([Board].self, for: type(of: self), pathVars: vars, queryParams: params, completionHandler: completionHandler);
    }

    private func setRightBarButtonItem() {
        menuButton.setImage(Asset.Assets.Icons.menu.image, for: .normal)
        menuButton.addTarget(self, action: #selector(moreAction), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = barButton
    }

    @objc
    private func moreAction() {
        openBoardMenu(board: parentBoard)
    }

    func openBoardMenu(board: Board) {
        let centerPoint = menuButton.superview?.convert(menuButton.frame.center, to: nil) ?? nil
        let presentedViewController = BoardMenuViewController(centerClosePoint: centerPoint)
        presentedViewController.needOpenCoverPhotoCallback = { [weak self] in
            if let boardId = self?.generalBoardId {
                let vc = BoardCoverPhotosViewController(boardId: boardId)
                vc.needUpdateCoverPhotoCallback = {
                    self?.needUpdateCoverPhoto?()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                self?.navigationController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.navigationController?.present(presentedViewController, animated: true, completion: nil)
    }
}

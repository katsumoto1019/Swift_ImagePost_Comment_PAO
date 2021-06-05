//
//  BoardSpotsViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/2/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Payload


class BoardSpotsViewController: SpotsViewController {
    var board: Board!
    var generalBoardId: String!
    var controllerType: AnyClass!
    var userId: String!
    var isMyBoard: Bool = false
    var needUpdateCoverPhoto: (() -> Void)?
    private lazy var menuButton: UIButton = UIButton()
    
    init(board: Board, generalBoardId: String, userId: String, controllerType: AnyClass, isMyBoard: Bool = false) {
        super.init(nibName: SpotsViewController.typeName, bundle: nil);
        
        self.board = board
        self.generalBoardId = generalBoardId
        self.userId = userId
        self.controllerType = controllerType
        self.isMyBoard = isMyBoard
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    func initialize() {
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.backgroundColor = ColorName.navigationBarTint.color
        screenName = "Saved Board Spots";
        if controllerType == UploadBoardCollectionViewController.self || controllerType == NestedUploadBoardCollectionViewController.self {
            spotTableViewController.showFavorites = true;
            screenName = "Upload Board Spots"
            if isMyBoard && generalBoardId == board.id {
                setRightBarItem()
            }
        }
        
        toggleLayout()
        self.spotTableViewController.disablePullToRefresh()
        collection.elementsChanged.append {[weak self] change in
            change?.forEach({ (elementChange) in
                switch elementChange {
                case .delete( _):
                    self?.popViewControllerIfEmpty(); return;
                default:
                    break;
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        title = board.title?.capitalized;
        popViewControllerIfEmpty();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = "";
    }
    
    override func setCacheKey() {
        collection.cacheKey = board.id;
    }
    
    func popViewControllerIfEmpty() {
        if !collection.isLoading && collection.count == 0 {
            navigationController?.popViewController(animated: true);
        }
    }
    
    func setRightBarItem() {
        menuButton.setImage(Asset.Assets.Icons.menu.image, for: .normal)
        menuButton.addTarget(self, action: #selector(morePressed), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: menuButton)
        if navigationItem.rightBarButtonItems == nil {
            navigationItem.rightBarButtonItems = []
        }
        navigationItem.rightBarButtonItems?.insert(barButton, at: 0)
    }
    
    @objc
    func morePressed() {
        let centerPoint = menuButton.superview?.convert(menuButton.frame.center, to: nil) ?? nil
        let presentedViewController = BoardMenuViewController(centerClosePoint: centerPoint)
        presentedViewController.needOpenCoverPhotoCallback = { [weak self] in
            if let board = self?.generalBoardId  {
                let vc = BoardCoverPhotosViewController(boardId: board)
                self?.navigationController?.pushViewController(vc, animated: true)
                vc.needUpdateCoverPhotoCallback = {
                    self?.needUpdateCoverPhoto?()
                }
            }
        }
        self.navigationController?.present(presentedViewController, animated: true, completion: nil)
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        if let boardId = board?.id {
            let vars = BoardSpotsVars(boardId: boardId);
            let params = BoardSpotsParams(skip: spotCollectionViewController.isReloading ? 0 : collection.count, take: collection.bufferSize, userId: userId);
            return App.transporter.get([Spot].self, for: controllerType, pathVars: vars, queryParams: params, completionHandler: completionHandler);
        } else {
            return nil
        }
    }
    
    override func didSelect(indexPath: IndexPath) {
        let event: EventAction = (controllerType == SaveBoardCollectionViewController.self || controllerType == NestedSaveBoardCollectionViewController.self) ? .selectSavesBoardSpot : .selectUploadsBoardSpot
        FirbaseAnalytics.logEvent(event)
        
        //Amplityde
        let isSavesBoard = (controllerType == SaveBoardCollectionViewController.self || controllerType == NestedSaveBoardCollectionViewController.self)
        let isMyProfile = userId == DataContext.cache.user.id
        
        let myProfileEvent: EventName = isSavesBoard ? .selectSavedBoardSpot : .selectUploadBoardSpot
        let othersProfileEvent: EventName = isSavesBoard ? .othersSavedBoardSpot : .othersUploadBoardSpot
        
        AmplitudeAnalytics.logEvent(isMyProfile ? myProfileEvent : othersProfileEvent, group: isMyProfile ? .myProfile : .otherProfile)
        ///
        
        var spots = [Spot]()
        for i in 0..<collection.count {
            spots.append(collection[i])
        }
        
        let viewController = ManualSpotsViewController.init(spots: spots);
        viewController.comesFrom = comesFrom
        viewController.title = board.title;
        viewController.scrolltoIndex = IndexPath(row: indexPath.row, section: 0);
        navigationController?.pushViewController(viewController, animated: false);
    }
}

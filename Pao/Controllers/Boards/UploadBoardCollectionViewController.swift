//
//  UploadBoardCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/7/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Payload


class UploadBoardCollectionViewController: RocketCollectionViewController<BoardCollectionViewCell>, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    private var emptyView: UIView = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center;
        paragraphStyle.lineSpacing = 6;
        
        let attributedText = NSMutableAttributedString(string: L10n.UploadBoardCollectionViewController.emptyViewText)
        attributedText.addAttributes([.paragraphStyle:paragraphStyle,.foregroundColor: UIColor.gray,.font: UIFont.app.withSize(UIFont.sizes.normal)], range: NSMakeRange(0, attributedText.length));
        let label = UILabel();
        label.numberOfLines = 0;
        label.attributedText = attributedText;
        label.font = UIFont.app.withSize(UIFont.sizes.normal)
        label.textColor = .gray
        return label;
    }()
    
    weak var delegate: BoardCollectionViewControllerDelegate?
    
    var searchPlaceholder = L10n.UploadBoardCollectionViewController.searchPlaceholder;
    let searchController = UISearchController(searchResultsController: nil)
    
    static public var uploadInProgress = false;
    public var isUserProfile = false;
    
    var userId: String!
    var generalBoardId: String?
    
    let dataSourcePrefetcher = DataSourcePrefetcher();
    
    init(userId: String, isUserProfile: Bool) {
        super.init();
        
        self.userId = userId
        self.isUserProfile = isUserProfile
    }
    
    init(userId: String) {
        super.init();
        
        self.userId = userId
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (isUserProfile) {
            // removeRefreshControl()
        }
        
        if userId == DataContext.cache.user?.id {
            collectionView.backgroundView = emptyView;
        }
        collectionView?.prefetchDataSource = dataSourcePrefetcher;
        setupSearchBar();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        
        // HACK?: Bottom cut off fix
        collectionView.translatesAutoresizingMaskIntoConstraints = false;
        let containerView = collectionView.superview!.superview!
        collectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true;
        collectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true;
        collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true;
        collectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 56).isActive = true;
        
        // refreshControl?.endRefreshing()
        // refreshControl?.removeFromSuperview()
        // refreshControl = nil;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
    }
    
    func setupSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.barStyle = .black
        searchBar.placeholder = searchPlaceholder
        searchBar.setTextFieldBorder()
        
        navigationItem.titleView = searchBar
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        guard !searchController.searchBar.isFirstResponder else {
        //            searchController.searchBar.resignFirstResponder()
        //            return;
        //        }
        
        let event: EventAction = (self is SaveBoardCollectionViewController) ? .selectSavesBoard : .selectUploadsBoard
        FirbaseAnalytics.logEvent(event)
        
        if userId == DataContext.cache.user.id { AmplitudeAnalytics.logEvent((self is SaveBoardCollectionViewController || self is NestedSaveBoardCollectionViewController) ? .selectSavedBoard : .selectUploadBoard, group: .myProfile)
        } else {
            AmplitudeAnalytics.logEvent((self is SaveBoardCollectionViewController || self is NestedSaveBoardCollectionViewController) ? .othersSavedBoard : .othersUploadBoard, group: .otherProfile)
        }
        
        let board = collection[indexPath.row]
        
        if type(of: self) == UploadBoardCollectionViewController.self {
            generalBoardId = board.id
        }
        
        if board.hasNestedBoards == true {
            showNestedBoards(board: board)
            return
        }
        
        let viewController = BoardSpotsViewController(board: board,
                                                      generalBoardId: generalBoardId ?? "",
                                                      userId: userId,
                                                      controllerType: type(of: self),
                                                      isMyBoard: userId == DataContext.cache.user.id)
        viewController.comesFrom = userId == DataContext.cache.user.id ? .ownProfile : .otherProfile
        viewController.needUpdateCoverPhoto = { [weak self] in
            guard let self = self else { return }
            self.updateCoverPhoto(needReload: false)
        }
        navigationController?.navigationController?.pushViewController(viewController, animated: true);
    }
    
    func showNestedBoards(board: Board) {
        let viewController = NestedUploadBoardCollectionViewController(
            userId: userId,
            parentBoard: board,
            generalId: generalBoardId ?? "")
        viewController.needUpdateCoverPhoto = { [weak self] in
            guard let self = self else { return }
            self.updateCoverPhoto(needReload: true)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    func updateCoverPhoto(needReload: Bool) {
        collection.removeAll()
        if needReload {
            collectionView?.reloadData()
        }
        collection.loadData(true)
    }
    
    //MARK: Search
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    @objc func updateResults(_ searchBar: UISearchBar) {
        collection.isLoading = false
        searchString = searchBar.text;
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        let event: EventAction = (self is SaveBoardCollectionViewController) ? .searchSaves : .searchUploads
        FirbaseAnalytics.logEvent(event)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        delegate?.lostFocus(self);
        if searchController.searchBar.text?.isEmpty ?? true {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar);
            perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 0.2);
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.gotFocus(self);
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.lostFocus(self);
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar);
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 0.2);
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let event: EventAction = (self is SaveBoardCollectionViewController) ? .searchSaves : .searchUploads
        FirbaseAnalytics.logEvent(event)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar);
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 0.2);
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    @objc func dismissKeyboard(tapGesture: UITapGestureRecognizer) {
        searchController.searchBar.resignFirstResponder();
    }
    
    override func getPayloads(completionHandler: @escaping ([BoardCollectionViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        let params = BoardsParams(skip: collection.count, take: collection.bufferSize, userId: userId, keyword: searchString);
        return App.transporter.get([Board].self, for: type(of: self), queryParams: params) { (result) in
            // self.removeRefreshControl()
            self.delegate?.boardLoadingDone(self)
            if self.userId == DataContext.cache.user.id &&
                UploadBoardCollectionViewController.uploadInProgress &&
                SaveBoardCollectionViewController.self != type(of: self) {
                if self.collection.count > 0, self.collection[0].isLocalBoard == true {
                    completionHandler(result);
                    return;
                }
                var boards: [Board] = result ?? [Board]();
                let localBoard = Board(isLocalBoard: true);
                boards.insert(localBoard, at: 0);
                completionHandler(boards);
                return;
            }
            
            completionHandler(result);
            
            // return App.transporter.get([Board].self, for: type(of: self), queryParams: params, completionHandler: completionHandler);
        }
    }
}

protocol FocusStateDelegate {
    func gotFocus(_ viewContoller: UploadBoardCollectionViewController);
    func lostFocus(_ viewContoller: UploadBoardCollectionViewController);
}

protocol BoardCollectionViewControllerDelegate: class, FocusStateDelegate {
    func boardLoadingDone(_ viewController: UploadBoardCollectionViewController)
}

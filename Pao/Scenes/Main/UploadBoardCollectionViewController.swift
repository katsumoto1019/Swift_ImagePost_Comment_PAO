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

class UploadBoardCollectionViewController: BasicCollectionViewController {
    
    weak var delegate: BoardCollectionViewControllerDelegate?
    var query: Query = DataContext.userUploadBoards.whereField("nestingLevel", isEqualTo: 0) {
        didSet {
            boardsRef = query;
        }
    }
    private var boardsRef: Query!
    
    var boardDocuments = [QueryDocumentSnapshot]()
    var isLoading = false {
        didSet {
            setupEmptyBoardView();
        }
    }
    let bufferSize = 30;
    var newBufferDelta: Int {
        return cellsPerRow * 2;
    }
    
    var kingfisherTasks = [Int: RetrieveImageTask]();

    var searchPlaceholder = "Search Uploads";
    let searchController = UISearchController(searchResultsController: nil);

    //Empty background view
    lazy var emptyBoardView: EmptyView = {
        let textTitle = "What is one of your favourite spots in the world?"
        let textSubTitle = "Find some of your photos of it and upload \n\n your first spot!";
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let text = String(format: "%@\n\n%@", textTitle, textSubTitle);
        let titleRange = (text as NSString).range(of: textTitle);
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [.paragraphStyle: paragraph]);
        
        attributedText.setAttributes([.foregroundColor: UIColor.cyan, .font: UIFont.appMedium.withSize(UIFont.sizes.small)], range: titleRange);
        
        let emptyView = EmptyView.loadFromNibNamed(nibNamed: EmptyView.typeName) as! EmptyView;
        emptyView.set(labelMessage: attributedText, image: nil);
        return emptyView;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.prefetchDataSource = self;
        self.collectionView?.refreshControl = UIRefreshControl();
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(reloadBoards), for: .valueChanged);

        // Register cell classes
        self.collectionView?.register(BoardCollectionViewCell.self);
        
        title = "";
        
        if boardsRef == nil {
            boardsRef = query;
        }
        
        setupBackgroundView();
        setupBottomRefresh();
        setupSearchBar();
        loadBoards();

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.searchResultsUpdater = self;
        searchController.delegate = self;
        
        let searchBar = searchController.searchBar;
        searchBar.delegate = self;
        searchBar.barStyle = .black;
        searchBar.placeholder = searchPlaceholder;
        navigationItem.titleView = searchBar;
    }
    
    @objc func reloadBoards() {
        loadBoards(reload: true);
    }
    
    func loadBoards(reload: Bool = false) {
        isLoading = true;
        var boardsRef = (self.boardsRef == query ? self.boardsRef.order(by: "timestamp", descending: true) : self.boardsRef).limit(to: bufferSize);
        
        if !reload, let lastDocument = boardDocuments.last {
            boardsRef = boardsRef.start(afterDocument: lastDocument);
        }
        
        if reload {
            boardDocuments.removeAll();
            collectionView?.reloadData();
        }
        
        boardsRef.getDocuments(completion: {(querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching document: \(error!)")
                self.isLoading = false;
                self.collectionView?.bottomRefreshControl?.endRefreshing();
                return
            }
            
            if (reload) {
                self.boardDocuments.removeAll();
                self.boardDocuments.append(contentsOf: documents);
                self.collectionView?.reloadData();
                self.collectionView?.refreshControl?.endRefreshing();
                if (self.boardDocuments.count > 0) {
                    self.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true);
                }
            }
            else {
                let initialIndex = self.boardDocuments.count;
                self.boardDocuments.append(contentsOf: documents);  
                var indexPaths = [IndexPath]();
                for index in initialIndex..<self.boardDocuments.count {
                    let indexPath = IndexPath(item: index, section: 0)
                    indexPaths.append(indexPath);
                }
                self.collectionView?.insertItems(at: indexPaths);
            }
            
            self.isLoading = false;
            self.activityIndicator.stopAnimating();
            self.collectionView?.bottomRefreshControl?.endRefreshing();
        })
    }

    func setupEmptyBoardView(){
        
        if isLoading == false &&  self.boardDocuments.count <= 0{
            collectionView?.backgroundView = emptyBoardView;
        }else if self.boardDocuments.count > 0, collectionView?.backgroundView is EmptyView {
            collectionView?.backgroundView = nil;
        }
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardDocuments.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.reuseIdentifier, for: indexPath) as! BoardCollectionViewCell
        
        let document = boardDocuments[indexPath.row];
        let board = try! document.convert(Board.self);
        let spotMediaItem = board.spots?.values.sorted(by: {$0.timestamp! > $1.timestamp!}).first?.media?.first?.value;
        let url = spotMediaItem?.type == 0 ? spotMediaItem?.url : spotMediaItem?.thumbnailUrl;
        cell.set(url: url, title: board.location?.title);
    
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == boardDocuments.count - 1 - newBufferDelta && !isLoading) {
            self.collectionView?.bottomRefreshControl?.beginRefreshing();
            loadBoards();
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        GoogleAnalytics.trackEvent(category: .uiAction, action: .tapImage, label: .board);
        
        let document = boardDocuments[indexPath.row];
        let board = try! document.convert(Board.self);
        
        if board.hasNestedBoards == true, let boardId = board.id {
            delegate?.showNestedBoards(self, boardId: boardId);
            return;
        }
        
        let viewController = BoardSpotsViewController(board: board);
        let navigationController = UINavigationController(rootViewController: viewController);
        self.present(navigationController, animated: true, completion: nil);
    }
}

extension UploadBoardCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let document = boardDocuments[indexPath.row];
            let board = try! document.convert(Board.self);
            if let url = board.spots?.first?.value.media?.first?.value.url {
                let servingUrl = url.imageServingUrl(cropSize: Int(cellWidth * UIScreen.main.scale));
                kingfisherTasks[indexPath.row] = KingfisherManager.shared.retrieveImage(with: servingUrl, options: nil, progressBlock: nil, completionHandler: nil);
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            kingfisherTasks[indexPath.row]?.cancel();
        }
    }
}

protocol BoardCollectionViewControllerDelegate: class, FocusStateDelegate {
    func showNestedBoards(_ viewController: UIViewController, boardId: String);
}


extension UploadBoardCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar);
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 2.0);
    }
    
    @objc func updateResults(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text, searchString.count > 0 else {
            if boardsRef != query {
                boardsRef = query;
                loadBoards(reload: true);
            }
            return;
        }
        
        let label: EventLabel = (self is SaveBoardCollectionViewController) ? .viewSaves : .viewUploads;
        GoogleAnalytics.trackEvent(category: .uiAction, action: .search, label: label);
        
        let endSearchString: String = searchString.appending("\u{f8ff}");
        boardsRef = query.order(by: "title").start(at: [searchString]).end(at: [endSearchString]);
        loadBoards(reload: true);
    }
}

extension UploadBoardCollectionViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        let label: EventLabel = (self is SaveBoardCollectionViewController) ? .viewSaves : .viewUploads;
        GoogleAnalytics.trackEvent(category: .uiAction, action: .search, label: label);
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        delegate?.lostFocus(self);
    }
}

extension UploadBoardCollectionViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.isUserInteractionEnabled = false;
        delegate?.gotFocus(self);
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.isUserInteractionEnabled = true;
        delegate?.lostFocus(self);
    }
}

protocol FocusStateDelegate {
    func gotFocus(_ viewContoller: UploadBoardCollectionViewController);
    func lostFocus(_ viewContoller: UploadBoardCollectionViewController);
}

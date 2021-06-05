//
//  PeopleSearchTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class PeopleSearchCollectionViewController: RocketCollectionViewController<PeopleSearchCollectionViewCell> {
    
    // MARK: - Internal properties
    
    override var cellsPerRow: Int { return 2 }
    override var cellSpacing: CGFloat { return 0 }
    
    // MARK: - Private properties
    
    private var firstLaunch = true
    private lazy var emptyView: UIView = {
        
        let noResultText = NSMutableAttributedString(
            string: L10n.PeopleSearchCollectionViewController.noResultText
        )
        noResultText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.appNormal.withSize(18),
            range: NSRange(location: 0, length: 5)
        )
        
        let label = UILabel()
        label.font = UIFont.app.withSize(UIFont.sizes.small)
        label.attributedText = noResultText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorName.textWhite.color
        
        let view = UIView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constraintToFit(inContainerView: view)
        view.isHidden = true
        return view
    }()
    private var users: [User]?
    private lazy var cacher = Cacher<String, [User]>(entryLifetime: 1 * 60 * 60) // 1 hour
    private let key = "PeopleSearch"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        screenName = "people_bubble_search"
        rocketCollection.cacheKey = "UserSearch"
        
        super.viewDidLoad()
        
        activityIndicatorView?.startAnimating()
        collectionView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        
        addSubViews()
        
        refreshControl?.endRefreshing()
        refreshControl?.removeFromSuperview()
        refreshControl = nil
        
        collectionView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLaunch {
            firstLaunch = false
        } else {
            collection.loadData(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCellSize()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = collection[indexPath.row]

        if let navController = navigationController {
            navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
            let viewController = UserProfileViewController(user: user)
            viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
            navController.pushViewController(viewController, animated: true)
        }
    }
    
    func loadData() {
        guard collection.count <= 0 else { return }
        
        collection.loadData(true)
    }
    
    override func getPayloads(completionHandler: @escaping ([User]?) -> Void) -> PayloadTask? {
        
        fetchData { users in
            DispatchQueue.main.async {
                completionHandler(users)
            }
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func addSubViews() {

        let headerStackView = UIStackView()
        headerStackView.axis = .vertical

        headerStackView.frame = CGRect(x: 0, y: -60, width: collectionView.frame.width, height: 55)
        
        headerStackView.backgroundColor = UIColor.clear
        
        let headLabel = UILabel()
        headLabel.numberOfLines = 0
        headLabel.text = L10n.PeopleSearchCollectionViewController.title
        headLabel.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(headLabel)
        headLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.large)
        styleLabel(label: headLabel)
        
        let subHeadingLabel = UILabel()
        subHeadingLabel.numberOfLines = 0
        subHeadingLabel.text = L10n.PeopleSearchCollectionViewController.subTitle
        subHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(subHeadingLabel)
        subHeadingLabel.font = UIFont.appLight.withSize(UIFont.sizes.small)
        styleLabel(label: subHeadingLabel)
        
        collectionView.addSubview(headerStackView)
    }
    
    private func styleLabel(label: UILabel) {
        label.textColor = ColorName.textWhite.color
        label.textAlignment = .center
    }
    
    private func setupCellSize() {
        
        let viewWidth = view.frame.size.width
        let cellWidth = (viewWidth - cellSpacing * CGFloat(cellsPerRow - 1)) / CGFloat(cellsPerRow)
        let cellHeight: CGFloat = 140 + 8 + 20 + 18 + 32
        
        guard let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionViewFlowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionViewFlowLayout.minimumLineSpacing = cellSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = cellSpacing
    }
    
    private func fetchData(completion: @escaping ([User]?) -> Void) {
        DispatchQueue.global(qos: .default).async {
            if let users = self.cacher.getData(with: self.key) {
                self.users = users
                completion(self.users)
            } else {
                self.fetchNetworkData(completion: completion)
            }
        }
    }
    
    private func fetchNetworkData(completion: @escaping ([User]?) -> Void) {
        App.transporter.get([User].self, for: type(of: self)) { [weak self] (users) in
            guard let self = self else { return }
            self.users = users
            self.cacher.save(users, key: self.key)
            completion(self.users)
        }
    }
}

extension UINavigationController {
    func setNavigationBarHiddenWithCustomAnimation(_ hide: Bool, animated: Bool) {
        func navigationBarIsHidden() -> Bool {
            return self.navigationBar.frame.origin.x < self.view.frame.minX
        }
        
        //if (navigationBarIsHidden() == hide) { return }

        // get a frame calculation ready
        let nWidth: CGFloat = self.navigationBar.frame.size.width
        let nOffsetX: CGFloat = (hide) ? -nWidth : nWidth

        // zero duration means no animation
        let duration: Double = (animated) ? 0.30 : 0.0

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            let nframe: CGRect = self.navigationBar.frame
            self.navigationBar.frame = nframe.offsetBy(dx: nOffsetX, dy: 0)
        }, completion: nil)
    }
    func setNavigationBarX(_ x: CGFloat) {
        var frame = self.navigationBar.frame
        frame.origin.x = x
        self.navigationBar.frame = frame
    }
}

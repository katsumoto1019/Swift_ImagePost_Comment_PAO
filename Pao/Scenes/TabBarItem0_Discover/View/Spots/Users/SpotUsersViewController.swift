//
//  SpotUsersViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 10/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class SpotUsersViewController: SwipeMenuViewController {
    
    private var viewControllers: [UITableViewController]!
	private var titles: [String] = []
    private var tabIndex: Int
    private var images: [UIImage] = []
    private var selected: Emoji?
    
    init(emojies: [Emoji: EmojiItem], selected: Emoji?, savedBy: [User]) {
        tabIndex = 0
        super.init(nibName: nil, bundle: nil)

        viewControllers = []
        self.selected = selected
        
        emojies
            .sorted(by: {
            return $0.key < $1.key
        })
            .forEach { item in
                self.images.append(item.key.image)
                self.titles.append(item.key.code)
            self.viewControllers.append(EmojiUsersTableViewController(emojiItems: item.value.reactedBy))
        }

        self.titles.append(L10n.SpotUsersViewController.titleSaved)
        self.images.append(Asset.Assets.Icons.saved.image)
        self.viewControllers.append(SaversTableViewController(users: savedBy))
        
        if let selectedEmoji = self.selected {
            self.titles.enumerated().forEach { index, item in
                if item == selectedEmoji.code  {
                    self.tabIndex = index
                }
            }
        } else {
            self.tabIndex = self.titles.count - 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        tabIndex = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers.forEach({
            $0.tableView.rowHeight = 65
            addChild($0)
            $0.didMove(toParent: self)
        })
        setupSwipe()
        swipeMenuView.jump(to: tabIndex, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if titles.count > swipeMenuView.currentIndex {
            FirbaseAnalytics.trackScreen(name: "\(titles[swipeMenuView.currentIndex]) Users")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //FirbaseAnalytics.trackScreen(name: "\(titles[swipeMenuView.currentIndex]) Users")
    }
    
    private func setupSwipe() {
        var options = SwipeMenuViewOptions()
        options.tabView.style = .segmented
        options.tabView.additionView.backgroundColor = UIColor.white
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = .white
        swipeMenuView.reloadData(options: options)
    }
    
    // MARK - SwipeMenuViewDataSource
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return viewControllers.count
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index]
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let viewController = viewControllers[index]
        return viewController
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        FirbaseAnalytics.trackScreen(name: "\(titles[toIndex]) Users")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, imageForPageAt index: Int) -> UIImage? {
        guard images.count > index else { return nil }
        return images[index]
    }
}

extension SpotUsersViewController: PullUpPresentationControllerDelegate {
	var canDismiss: Bool {
        return true
    }
}

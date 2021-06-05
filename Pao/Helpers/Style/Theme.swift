//
//  Theme.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import MessageUI

class Theme {
    
}

extension Theme {
    func apply() {
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = ColorName.navigationBarTint.color
        }
        
        styleNavigationBar();
        
        styleView();
        
        styleLabel();
        styleTextField();
        styleTextView();
        styleImageView();
        styleButton();
        
        styleTableViewCell();
        styleTableView();
        
        styleCollectionView();
        
        styleTabBar();
        styleTabBarItem();
        
        styleAlert();
    }
    
    private func styleNavigationBar() {
        let navigationBar = UINavigationBar.appearance();
        navigationBar.barTintColor = ColorName.navigationBarTint.color
        navigationBar.isTranslucent = false;
        
        let renderedImage = Asset.Assets.Icons.leftArrowNav.image.withRenderingMode(.alwaysOriginal)
        navigationBar.backIndicatorImage = renderedImage
        navigationBar.backIndicatorTransitionMaskImage = renderedImage
       
        //hide backButton title
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -500.0, vertical: 0.0), for: .default)

        let font = UIFont.app.withSize(20);
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ColorName.navigationBarText.color, NSAttributedString.Key.font: font
        ];
    }
    
    private func styleView() {
    }
    
    private func styleLabel() {
        var label = UILabel.appearance();
        label.font = UIFont.app;
        label.textColor = ColorName.textWhite.color
        
        // KeyValueCell
        label = UILabel.appearance(whenContainedInInstancesOf: [KeyValueEditableViewCell.self]);
        label.textColor = ColorName.textGray.color
        label.set(fontSize: UIFont.sizes.small);
        
        label = UILabel.appearance(whenContainedInInstancesOf: [GoContactTableViewCell.self]);
        label.set(fontSize: UIFont.sizes.small);
        
        // AboutmeLocation
        label = UILabel.appearance(whenContainedInInstancesOf: [AboutMeLocationTableViewCell.self]);
        label.font = UIFont.app.withSize(UIFont.sizes.small)
        
        label = UILabel.appearance(whenContainedInInstancesOf: [AlbumSelectTableViewCell.self]);
        label.textColor = UIColor.black;
    }
    
    private func styleTextView() {
        var textView = UITextView.appearance();
        textView.backgroundColor = UIColor.clear;
        textView.font = UIFont.app;
        
        textView = UITextView.appearance(whenContainedInInstancesOf: [BaseViewController.self]);
        textView.textColor = ColorName.textWhite.color
        
      //  textView = UITextView.appearance(whenContainedInInstancesOf: [UITableViewCell.self]);
        //textView.textColor = ColorName.textWhite.color
        

        // QUES: Why does this cause the app to crash?
        //textView.keyboardAppearance = .dark;
    }
    
    private func styleTextField() {
        var textField = UITextField.appearance();
        textField.backgroundColor = UIColor.clear;
        textField.textColor = ColorName.textWhite.color
        textField.font = UIFont.app;
        textField.keyboardAppearance = .dark;
        
        textField = UITextField.appearance(whenContainedInInstancesOf: [ProfileViewController.self]);
        textField.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: ColorName.textWhite.color,
            NSAttributedString.Key.font: UIFont.app.withSize(UIFont.sizes.small)
        ];
        
        // Google Places Controller
        textField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]);
        textField.defaultTextAttributes = [NSAttributedString.Key.foregroundColor: ColorName.textWhite.color]
    
        // KeyValueCell
        textField = UITextField.appearance(whenContainedInInstancesOf: [KeyValueEditableViewCell.self]);
        textField.textAlignment = .left;
        textField.set(fontSize: UIFont.sizes.small);
        
       let isaoTextField = IsaoTextField.appearance();
        isaoTextField.font = UIFont.app.withSize(UIFont.sizes.normal);
        isaoTextField.errorTextColor = ColorName.accent.color
        isaoTextField.borderInactiveColor = UIColor.white;
        isaoTextField.borderActiveColor = ColorName.accent.color
        isaoTextField.borderStyle = .none
    }
    
    private func styleImageView() {
        // Google Places Controller, Search bar round style
        var imageView = UIImageView.appearance(whenContainedInInstancesOf: [UISearchBar.self]);
        imageView.clipsToBounds = imageView.clipsToBounds;
        imageView.contentMode = imageView.contentMode;
        
        imageView = UIImageView.appearance(whenContainedInInstancesOf: [UITableView.self, UICollectionView.self]);
        imageView.clipsToBounds = true;
        imageView.contentMode = .scaleAspectFill;
        
        imageView = UIImageView.appearance(whenContainedInInstancesOf: [GoContactTableViewCell.self]);
        imageView.contentMode = .center;
    }
    
    private func styleButton() {
        var button = UIButton.appearance(whenContainedInInstancesOf: [ProfileImageViewCell.self]);
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6);
        button.setTitleColor(UIColor.black, for: .normal);
        button.titleLabel?.set(fontSize: UIFont.sizes.small);
        button.titleEdgeInsets.left = 10;
        
        button = UIButton.appearance(whenContainedInInstancesOf: [GoContactTableViewCell.self]);
        button.titleLabel?.set(fontSize: UIFont.sizes.small);
        button.backgroundColor = ColorName.accent.color
        
        button = UIButton.appearance(whenContainedInInstancesOf: [RegisterViewController.self]);
        button.titleLabel?.set(fontSize: UIFont.sizes.small);
        button.backgroundColor = UIColor.clear;
    }
    
    private func styleTableViewCell() {
        var tableViewCell = UITableViewCell.appearance(whenContainedInInstancesOf: [UITableViewController.self]);
        tableViewCell.backgroundColor = ColorName.background.color
        tableViewCell.selectionStyle = .none;
        
        tableViewCell = UITableViewCell.appearance(whenContainedInInstancesOf: [AboutMeTableViewController.self]);
        tableViewCell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.1);
        
         tableViewCell = UITableViewCell.appearance(whenContainedInInstancesOf: [AboutMeStatsTableViewCell.self]);
        tableViewCell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.1);
        
        tableViewCell = UITableViewCell.appearance(whenContainedInInstancesOf: [AlbumSelectTableViewController.self]);
        tableViewCell.backgroundColor = UIColor.white;
    }
    
    private func styleTableView() {
        var tableView = UITableView.appearance();
        tableView.separatorColor = UIColor.darkGray;
        tableView.backgroundColor = ColorName.background.color
        
        tableView = UITableView.appearance(whenContainedInInstancesOf: [SpotTableViewController.self]);
        tableView.separatorInset.left = 8;
        tableView.separatorInset.right = 8;
        
        tableView = UITableView.appearance(whenContainedInInstancesOf: [SpotUsersViewController.self]);
        tableView.separatorColor = UIColor.clear;
        
//        tableView = UITableView.appearance(whenContainedInInstancesOf: [LocationsSearchCollectionViewController.self]);
//        tableView.separatorInset.left = 32;
    }
    
    func styleCollectionView() {
        let collectionView = UICollectionView.appearance();
        collectionView.backgroundColor = ColorName.background.color
    }
    
    private func styleTabBar() {
        let tabBar = UITabBar.appearance();
        tabBar.barTintColor = ColorName.navigationBarTint.color
        tabBar.isTranslucent = false;
        // Remove border and shadow
        tabBar.backgroundImage = UIImage();
        tabBar.shadowImage = UIImage();
        tabBar.unselectedItemTintColor = ColorName.textGray.color
        tabBar.tintColor = ColorName.accent.color
    }
    
    func styleTabBarItem() {
//        let tabBarItem = UITabBarItem.appearance();
    }
    
    private func styleAlert() {
        let view = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]);
        if #available(iOS 13.0, *) {
        view.tintColor = UIColor.label
        } else {
            view.tintColor = UIColor.black
        }

    }
}

extension UIApplication {
    // HACK: Private api.
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}

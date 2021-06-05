//
//  UsersTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/9/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: StyledTableViewController {
    var isLoading = false;
    var userDocuments = [DocumentSnapshot]()

    let usersQuery: Query = DataContext.users.order(by: "name");
    var usersRef: Query = DataContext.users.order(by: "name");
    
    let bufferSize = 20;
    var newBufferDelta: Int = 6;
    
    let searchController = UISearchController(searchResultsController: nil);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "User List";
        
        tableView.register(UserViewCell.self);
        
        title = "Pao People";
        navigationItem.backBarButtonItem = UIBarButtonItem();
        
        loadUsers();
        setupSearch();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        searchController.dismiss(animated: false);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSearch() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self;
        searchController.delegate = self;
        
        let searchBar = searchController.searchBar;
        searchBar.barStyle = .black;
        tableView.tableHeaderView = searchBar;
    }
    
    // TODO: Refactor to handle infinite load at one place
    func loadUsers(reload: Bool = false) {
        isLoading = true;
        var usersRef = self.usersRef.limit(to: bufferSize);
        
        if !reload, let lastDocument = userDocuments.last {
            usersRef = usersRef.start(afterDocument: lastDocument);
        }
        
        usersRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching document: \(error!)")
                self.isLoading = false;
                return
            }
            
            if (reload) {
                self.userDocuments.removeAll();
                self.userDocuments.append(contentsOf: documents);
                self.tableView.reloadData();
                self.tableView.refreshControl?.endRefreshing();
            }
            else {
                let initialIndex = self.userDocuments.count;
                self.userDocuments.append(contentsOf: documents);
                
                var indexPaths = [IndexPath]();
                for index in initialIndex..<self.userDocuments.count {
                    let indexPath = IndexPath(item: index, section: 0)
                    indexPaths.append(indexPath);
                }
                
                //insertRows was glichi.
                //self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.bottom);
                self.tableView.reloadData()
            }
            
            self.isLoading = false;
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == userDocuments.count - newBufferDelta {
            loadUsers();
        }
    }
}

extension UsersTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDocuments.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserViewCell.reuseIdentifier, for: indexPath) as! UserViewCell;
        
        let user = try! userDocuments[indexPath.row].convert(User.self);
        cell.set(user: user);
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.dismiss(animated: true, completion: nil);
//        let viewController = UserProfileViewController(userDocument: userDocuments[indexPath.row]);
//        navigationController?.pushViewController(viewController, animated: true);
    }
}

extension UsersTableViewController: UISearchResultsUpdating {
    // REF: https://stackoverflow.com/questions/24330056/how-to-throttle-search-based-on-typing-speed-in-ios-uisearchbar
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar);
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 2.0);
    }
    
    @objc func updateResults(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text?.capitalized, searchString.count > 0 else {
            if usersRef != usersQuery {
                usersRef = usersQuery;
                loadUsers(reload: true);
            }
            return;
        }
        //FirbaseAnalytics.trackEvent(category: .uiAction, action: .search, label: .viewUsers)
        let endSearchString: String = searchString.appending("\u{f8ff}");
        usersRef = DataContext.users.order(by: "name").start(at: [searchString]).end(at: [endSearchString]);
        loadUsers(reload: true);
    }
}

extension UsersTableViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        //FirbaseAnalytics.trackEvent(category: .uiAction, action: .tapSearch, label: .viewUsers)

    }
}

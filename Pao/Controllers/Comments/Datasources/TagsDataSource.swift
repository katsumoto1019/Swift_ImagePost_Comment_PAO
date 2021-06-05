//
//  SuggestionsDataSource.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class TagsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var users = [User]()
    var tag: TagKeyword?
    
    public var callBack : ((_ taggedData: (TagKeyword)?,_ user: User) -> Void)?
    
    override init() {
        super.init();
    }
    
    func getTags(forTagKeyword tagKeyword: TagKeyword,completionHandler: (() -> Void)? = nil) {
        tag = tagKeyword;
        loadData(reload: true, completionHandler: completionHandler);
    }
    
    func user(at indexPath:IndexPath) -> User? {
        
        guard indexPath.row < users.count  else { return nil; }
        
        return  users[indexPath.row];
    }
    
    func linkWith(tableview: UITableView) {
        tableview.delegate = self;
        tableview.dataSource = self;
         tableview.reloadData();
    }
    
    //--------Tableview DataSource and Delegate functions--------------//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagTableViewCell.reuseIdentifier) as! TagTableViewCell;
        cell.set(user: users[indexPath.row]);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = user(at: indexPath) {
            self.callBack?(tag,user);
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil;
    }
}

extension TagsDataSource: APIDataSource {

    func loadData(reload: Bool = false,  completionHandler: (() -> Void)? = nil) {
        let params = UsersParams(skip: 0, take: 10, keyword: tag?.keyword?.replacingOccurrences(of: "@", with: ""));
        App.transporter.get([User].self, for: type(of: self), queryParams: params) { (result) in
            if let new = result {
                 self.users.removeAll()
                self.users.append(contentsOf: new);
            }
            completionHandler?();
        }
    }
}

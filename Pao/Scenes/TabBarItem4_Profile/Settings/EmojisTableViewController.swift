//
//  EmojisTableViewController.swift
//  Pao
//
//  Created by Ajay on 05/08/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit


class EmojisTableViewController: StyledTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Emojis"
        
        tableView.register(EmojiTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.contentInset.top = 24
        
        navigationController?.navigationBar.backgroundColor = ColorName.navigationBarTint.color
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = L10n.EmojisTableViewController.title
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmojiTableViewCell.reuseIdentifier, for: indexPath);
        return cell
    }
}

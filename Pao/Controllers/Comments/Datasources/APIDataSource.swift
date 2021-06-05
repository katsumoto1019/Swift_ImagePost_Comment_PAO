//
//  APIDataSource.swift
//  Pao
//
//  Created by kant on 28.04.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

protocol APIDataSource {
    func loadData(reload: Bool, completionHandler: (() -> Void)?)
}

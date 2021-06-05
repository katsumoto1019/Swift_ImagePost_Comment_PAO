//
//  CachedSpotsViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 07/11/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import Payload

class CachedSpotsViewController: SpotsViewController {
	
	// MARK: - Lifecycle
	
    init() {
        super.init(nibName: SpotsViewController.typeName, bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
	
	// MARK: - SpotsViewController implementation
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
		
		let path = getDocumentsDirectory().appendingPathComponent("feed")
		
         if
			collection.isEmpty,
			!isCacheLoaded,
			let cachedSpotsData = try? Data(contentsOf: path) {
               if !isCacheLoaded,
				let cachedSpots = try? JSONDecoder().decode([Spot].self, from: cachedSpotsData) {
                   collection.append(contentsOf: cachedSpots)
                   isCacheLoaded = true
               }
        }
        
        return nil
    }
	
	// MARK: - Private methods
	
	private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

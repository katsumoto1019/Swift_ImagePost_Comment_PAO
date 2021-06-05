//
//  Cacher.swift
//  SwiftCacher
//
//  Created by kant on 02.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

final class Cacher<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval // in seconds
    private let keyTracker = KeyTracker()
    
    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 1 * 60 * 60, // 1 hour by default
         maximumEntryCount: Int = 50) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
    
    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }
        
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry.value
    }
    
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

private extension Cacher {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }
}

private extension Cacher {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

extension Cacher {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}

// KeyTracker - cache observer & count limiter

private extension Cacher {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            
            keys.remove(entry.key)
        }
    }
}

// Value type entities save to disk

extension Cacher.Entry: Codable where Key: Codable, Value: Codable {}

private extension Cacher {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

extension Cacher: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry) )
    }
}

extension Cacher where Key: Codable, Value: Codable {
    func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        try data.write(to: fileURL)
    }
    
    func getFromDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws -> Value {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let cache = try decoder.decode([Entry].self, from: data).first else {
                throw CacherError.cacheIsNil
            }
            
            let expirationDate = cache.expirationDate
            guard dateProvider() < expirationDate else {
                throw CacherError.dataHasExpired
            }
            
            return cache.value
            
        } catch {
            print(error)
            throw CacherError.failedDecode
        }
    }
    
    func save(_ entity: Value?, key: Key) {
        guard let entity = entity else { return }
        
        // skip disk persistance
        //let cacherDiskKey = "Disk\(key)"
        
        insert(entity, forKey: key)
        
        /* skip disk persistance
        do {
            try saveToDisk(withName: cacherDiskKey)
            #if DEBUG
            print("✅ Success save entity")
            #endif
        } catch {
            #if DEBUG
            print("\n⛔️ Failed to save data to cache: \(error.localizedDescription)")
            #endif
        }
        */
    }
    
    func getData(with key: Key) -> Value? {
        if let entity = value(forKey: key) {
            #if DEBUG
            print("\n✅ Successfully retrieved cache data:")
            dump(entity)
            #endif
            return entity
        } else {
            //skip disk persistance
            return nil
        }
        
        /* skip disk persistance
        let cacherDiskKey = "Disk\(key)"
         
        do {
            let entity = try getFromDisk(withName: cacherDiskKey)
            //let entity = cacher.value(forKey: cacherCacheKey)
            #if DEBUG
            print("\n✅ Successfully retrieved disk/cache data:")
            dump(entity)
            #endif
            
            return entity
        } catch {
            #if DEBUG
            print("\nFailed to get data from cache or empty: \(error)")
            #endif
            return nil
        }
        */
    }
	
	func removeFullData(forKey key: Key, using fileManager: FileManager = .default) {
		removeValue(forKey: key)
		
		guard let name = key as? String else { return }
		
		let folderURLs = fileManager.urls(
			for: .cachesDirectory,
			in: .userDomainMask
		)
		
		guard let folderURL = folderURLs.first else { return }
		let diskFileName = "Disk\(name)" + ".cache"
		
		do {
			let fileNames = try fileManager.contentsOfDirectory(atPath: folderURL.path)
			guard fileNames.contains(diskFileName) else { return }
			print("all files in cache: \(fileNames)")
			
			let filePathName = folderURL.appendingPathComponent(diskFileName)
			try fileManager.removeItem(atPath: filePathName.path)
		} catch {
			#if DEBUG
			print("\n\n⛔️ Cache file not found: \(error)")
			#endif
		}
	}
	
	
    
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

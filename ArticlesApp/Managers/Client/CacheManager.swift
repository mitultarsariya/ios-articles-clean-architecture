//
//  CacheManager.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation
import Cache

// MARK: - Protocol
protocol CacheManagerProtocol {
    func save<T: Codable>(_ object: T, forKey key: String)
    func load<T: Codable>(forKey key: String) -> T?
    func remove(forKey key: String)
    func clearAll()
    func hasCache(forKey key: String) -> Bool
}

// MARK: - Implementation
final class CacheManager: CacheManagerProtocol {

    // Single Storage<String, Data> backing store.
    // I encode everything to Data so one store handles all types.
    private var storage: Storage<String, Data>?
    private let log = AppLogger.shared

    init() {
        setupStorage()
    }

    // MARK: - Public API

    func save<T: Codable>(_ object: T, forKey key: String) {
        guard let storage else {
            log.error("CacheManager: storage not initialised — skipping save [\(key)]")
            return
        }
        do {
            let data = try JSONEncoder().encode(object)
            try storage.setObject(data, forKey: key)
            log.debug("💾 Cache WRITE → \(key) (\(data.count) bytes)")
        } catch {
            log.error("Cache save failed [\(key)]: \(error.localizedDescription)")
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        guard let storage else {
            log.error("CacheManager: storage not initialised — cannot load [\(key)]")
            return nil
        }
        do {
            let data  = try storage.object(forKey: key)
            let value = try JSONDecoder().decode(T.self, from: data)
            log.debug("📦 Cache HIT → \(key)")
            return value
        } catch {
            log.debug("📭 Cache MISS → \(key): \(error.localizedDescription)")
            return nil
        }
    }

    func remove(forKey key: String) {
        do {
            try storage?.removeObject(forKey: key)
            log.debug("🗑 Cache REMOVE → \(key)")
        } catch {
            log.warning("Cache remove failed [\(key)]: \(error.localizedDescription)")
        }
    }

    func clearAll() {
        do {
            try storage?.removeAll()
            log.info("🗑 Cache CLEARED — all entries removed")
        } catch {
            log.warning("Cache clearAll failed: \(error.localizedDescription)")
        }
    }

    func hasCache(forKey key: String) -> Bool {
        guard let storage else { return false }
        do {
            return try storage.existsObject(forKey: key)
        } catch {
            return false
        }
    }

    // MARK: - Private Setup

    private func setupStorage() {
        let diskConfig = DiskConfig(
            name: "ArticlesAppDiskCache",
            expiry: .seconds(AppConstants.Cache.expiryDuration),  // 1 hour
            maxSize: 10_000_000   // 10 MB disk limit
        )
        let memoryConfig = MemoryConfig(
            expiry: .seconds(300),    // 5 min hot in-memory
            countLimit: 50,
            totalCostLimit: 0
        )
        do {
            storage = try Storage<String, Data>(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                transformer: TransformerFactory.forData()
            )
            log.info("✅ CacheManager storage initialised")
        } catch {
            log.error("🔥 CacheManager storage init failed: \(error.localizedDescription)")
            storage = nil
        }
    }
}

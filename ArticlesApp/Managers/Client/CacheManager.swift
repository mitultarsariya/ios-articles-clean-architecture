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
}

// MARK: - Implementation
final class CacheManager: CacheManagerProtocol {

    private var storage: Storage<String, Data>?
    private let log = AppLogger.shared

    init() { setupStorage() }

    // MARK: - Public
    func save<T: Codable>(_ object: T, forKey key: String) {
        guard let storage else { return }
        do {
            let data = try JSONEncoder().encode(object)
            try storage.setObject(data, forKey: key)
            log.debug("💾 Cached \(T.self) → \(key)")
        } catch {
            log.error("Cache save failed [\(key)]: \(error.localizedDescription)")
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        guard let storage else { return nil }
        do {
            let data = try storage.object(forKey: key)
            let value = try JSONDecoder().decode(T.self, from: data)
            log.debug("📦 Cache HIT → \(key)")
            return value
        } catch {
            log.debug("📭 Cache MISS → \(key)")
            return nil
        }
    }

    func remove(forKey key: String) {
        try? storage?.removeObject(forKey: key)
        log.debug("🗑 Cache cleared → \(key)")
    }

    func clearAll() {
        try? storage?.removeAll()
        log.info("🗑 Full cache cleared")
    }

    // MARK: - Private
    private func setupStorage() {
        let disk = DiskConfig(
            name: "ArticlesAppDiskCache",
            expiry: .seconds(AppConstants.Cache.expiryDuration),
            maxSize: 10_000_000   // 10 MB
        )
        let memory = MemoryConfig(
            expiry: .seconds(300),    // 5 min hot cache
            countLimit: 50,
            totalCostLimit: 0
        )
        do {
            storage = try Storage<String, Data>(
                diskConfig: disk,
                memoryConfig: memory,
                transformer: TransformerFactory.forData()
            )
            log.info("Cache storage initialised ✓")
        } catch {
            log.error("Cache initialisation failed: \(error.localizedDescription)")
        }
    }
}


//
//  ArticleManager.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

// MARK: - Protocol
protocol ArticleManagerProtocol {
    func getArticles(
        forceRefresh: Bool,
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    )
}

// MARK: - CacheSource — lets ViewController know where data came from
enum ArticleDataSource {
    case network
    case cache
}

// MARK: - Implementation
final class ArticleManager: ArticleManagerProtocol {

    private let provider:     ArticleProviderProtocol
    private let cache:        CacheManagerProtocol
    private let reachability: ReachabilityManagerProtocol
    private let log = AppLogger.shared

    init(
        provider:     ArticleProviderProtocol,
        cache:        CacheManagerProtocol,
        reachability: ReachabilityManagerProtocol
    ) {
        self.provider     = provider
        self.cache        = cache
        self.reachability = reachability
    }

    // MARK: - Public

    func getArticles(
        forceRefresh: Bool = false,
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        // ── OFFLINE PATH ───────────────────────────────────────────
        guard reachability.isConnected else {
            log.warning("📵 Device offline — attempting cache fallback")
            serveCacheOrFail(completion: completion)
            return
        }

        // ── CACHE-FIRST PATH (not a force refresh) ─────────────────
        if !forceRefresh {
            if let cached: ArticleResponse = cache.load(
                forKey: AppConstants.Cache.articlesCacheKey
            ) {
                let articles = filter(cached.articles)
                log.debug("⚡️ Serving \(articles.count) articles from cache (cache-first)")
                completion(.success(articles))
                return
            }
        }

        // ── NETWORK PATH ───────────────────────────────────────────
        log.info("🌐 Fetching articles from network (forceRefresh: \(forceRefresh))")
        provider.fetchArticles { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                // Persist to cache immediately after successful fetch
                self.cache.save(response, forKey: AppConstants.Cache.articlesCacheKey)
                let articles = self.filter(response.articles)
                self.log.info("✅ Network fetch success — \(articles.count) valid articles cached")
                completion(.success(articles))

            case .failure(let networkError):
                self.log.error("❌ Network fetch failed: \(networkError.errorDescription ?? "unknown")")
                // Graceful degradation — serve stale cache on network error
                self.serveCacheOrFail(
                    overrideError: networkError,
                    completion: completion
                )
            }
        }
    }

    // MARK: - Private

    /// Attempts to serve from cache; calls completion with .failure if cache is also empty.
    private func serveCacheOrFail(
        overrideError: NetworkError? = nil,
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        if let cached: ArticleResponse = cache.load(
            forKey: AppConstants.Cache.articlesCacheKey
        ) {
            let articles = filter(cached.articles)
            log.warning("📦 Serving \(articles.count) articles from stale cache")
            completion(.success(articles))
        } else {
            // No cache at all — surface the most relevant error
            let error = overrideError ?? .noInternetConnection
            log.error("🚫 No cache available. Surfacing error: \(error.errorDescription ?? "")")
            completion(.failure(error))
        }
    }

    /// Removes tombstoned/removed articles from the API feed.
    private func filter(_ articles: [Article]) -> [Article] {
        articles.filter(\.isValid)
    }
}

//
//  ArticleManager.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

// MARK: - Protocol
protocol ArticleManagerProtocol {
    func getArticles(forceRefresh: Bool,
                     completion: @escaping (Result<[Article], NetworkError>) -> Void)
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
        // ── Offline path ──────────────────────────────────────
        guard reachability.isConnected else {
            log.warning("Offline → attempting cache fallback")
            if let cached: ArticleResponse = cache.load(forKey: AppConstants.Cache.articlesCacheKey) {
                completion(.success(filtered(cached.articles)))
            } else {
                completion(.failure(.noInternetConnection))
            }
            return
        }

        // ── Cache-first (when not forcing refresh) ────────────
        if !forceRefresh,
           let cached: ArticleResponse = cache.load(forKey: AppConstants.Cache.articlesCacheKey) {
            log.debug("Returning cache-first articles")
            completion(.success(filtered(cached.articles)))
            return
        }

        // ── Network path ──────────────────────────────────────
        log.info("Fetching articles from network…")
        provider.fetchArticles { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.cache.save(response, forKey: AppConstants.Cache.articlesCacheKey)
                let articles = self.filtered(response.articles)
                self.log.info("Fetched \(articles.count) valid articles")
                completion(.success(articles))

            case .failure(let error):
                self.log.error("Network fetch failed: \(error.errorDescription ?? "?")")
                // Graceful degradation → serve stale cache on error
                if let stale: ArticleResponse = self.cache.load(forKey: AppConstants.Cache.articlesCacheKey) {
                    self.log.warning("Serving stale cache after network failure")
                    completion(.success(self.filtered(stale.articles)))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Private
    private func filtered(_ articles: [Article]) -> [Article] {
        articles.filter(\.isValid)
    }
}


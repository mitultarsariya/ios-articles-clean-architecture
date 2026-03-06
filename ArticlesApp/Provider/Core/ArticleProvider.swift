//
//  ArticleProvider.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

final class ArticleProvider: ArticleProviderProtocol {

    private let client: NetworkClientProtocol
    private let log = AppLogger.shared

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func fetchArticles(completion: @escaping (Result<ArticleResponse, NetworkError>) -> Void) {
        log.debug("ArticleProvider → fetchArticles()")
        client.request(endpoint: .articles, parameters: nil, completion: completion)
    }
}


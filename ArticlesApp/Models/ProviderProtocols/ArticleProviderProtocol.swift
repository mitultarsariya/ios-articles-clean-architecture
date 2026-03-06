//
//  ArticleProviderProtocol.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

protocol ArticleProviderProtocol {
    func fetchArticles(completion: @escaping (Result<ArticleResponse, NetworkError>) -> Void)
}


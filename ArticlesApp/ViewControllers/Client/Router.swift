//
//  Router.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit

// MARK: - Protocol
protocol RouterProtocol {
    func navigateToDetail(from vc: UIViewController, with article: Article)
}

// MARK: - Implementation
final class Router: RouterProtocol {

    private let log = AppLogger.shared

    func navigateToDetail(from vc: UIViewController, with article: Article) {
        guard let detailVC = AppDIContainer.shared
                .resolve(ArticleDetailViewController.self) else {
            log.error("Router: failed to resolve ArticleDetailViewController")
            return
        }

        detailVC.article = article

        vc.navigationController?.pushViewController(detailVC, animated: true)
        log.debug("→ ArticleDetail: \(article.title.prefix(40))")
    }
}



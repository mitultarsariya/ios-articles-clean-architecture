//
//  AppConstants.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit

enum AppConstants {
    
    enum UI {
        static let cardCornerRadius:   CGFloat = 12.0
        static let imageCornerRadius:  CGFloat = 8.0
        static let buttonCornerRadius: CGFloat = 8.0
        static let shadowRadius:       CGFloat = 6.0
        static let shadowOpacity:      Float   = 0.10
        static let shadowOffsetY:      CGFloat = 3.0
    }

    enum Fonts {
        static let articleTitle  = UIFont.boldSystemFont(ofSize: 16)
        static let articleDate   = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let detailTitle   = UIFont.boldSystemFont(ofSize: 22)
        static let detailContent = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let sourceName    = UIFont.systemFont(ofSize: 12, weight: .medium)
    }

    enum Cache {
        /// Key used to read/write the ArticleResponse in CacheManager
        static let articlesCacheKey = "com.articlesapp.cache.articles"

        /// Cache expiry: 1 hour. Stale data is served offline after expiry
        /// but the network will refresh it once connectivity is restored.
        static let expiryDuration: TimeInterval = 3_600
    }

    enum Storyboard {
        static let main             = "Main"
        static let articleListVC    = "ArticleListViewController"
        static let articleDetailVC  = "ArticleDetailViewController"
    }

    enum Xib {
        static let articleCell = "ArticleTableViewCell"
    }
}


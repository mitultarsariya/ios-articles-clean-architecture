//
//  Article.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

// MARK: - ArticleResponse
struct ArticleResponse: Codable {
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable, Equatable {
    let source: ArticleSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    /// Filters out "tombstoned" articles removed by the API provider
    var isValid: Bool {
        return title != "[Removed]"
            && url != "https://removed.com"
            && !title.isEmpty
    }

    var publishedDate: Date? {
        ISO8601DateFormatter().date(from: publishedAt)
    }

    var formattedDate: String {
        guard let date = publishedDate else { return publishedAt }
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM, yyyy"
        return fmt.string(from: date)
    }

    var relativeTime: String {
        guard let date = publishedDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var validImageURL: URL? {
        guard let raw = urlToImage, !raw.isEmpty else { return nil }
        return URL(string: raw)
    }
}

// MARK: - ArticleSource
struct ArticleSource: Codable, Equatable {
    let id: String?
    let name: String
}



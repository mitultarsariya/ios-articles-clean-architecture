//
//  ArticleListViewState.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

enum ArticleListViewState {
    case idle
    case loading
    case success([Article])
    case empty
    case error(String)
}


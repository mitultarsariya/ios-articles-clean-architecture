//
//  ArticleDetailViewState.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

enum ArticleDetailViewState {
    case idle
    case loaded(Article)
    case error(String)
}


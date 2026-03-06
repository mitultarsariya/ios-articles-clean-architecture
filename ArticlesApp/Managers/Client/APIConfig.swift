//
//  APIConfig.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

enum APIConfig {
    static let baseURL:         String     = Environment.current.baseURL
    static let timeoutInterval: TimeInterval = 30.0
}


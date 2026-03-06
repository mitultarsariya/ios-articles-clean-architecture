//
//  APIEndpoints.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

enum APIEndpoints {
    case articles

    var path: String {
        switch self {
        case .articles:
            return "/v1/50422b19-547f-41c0-b623-e82d886ad264"
        }
    }

    var httpMethod: String { "GET" }
}


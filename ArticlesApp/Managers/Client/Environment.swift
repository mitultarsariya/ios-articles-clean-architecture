//
//  Environment.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }

    var baseURL: String {
        switch self {
        case .development, .staging: return "https://mocki.io"
        case .production:            return "https://mocki.io"
        }
    }

    var isLoggingEnabled: Bool {
        switch self {
        case .development, .staging: return true
        case .production:            return false
        }
    }

    var logLevel: String {
        switch self {
        case .development: return "DEBUG"
        case .staging:     return "INFO"
        case .production:  return "WARNING"
        }
    }
}


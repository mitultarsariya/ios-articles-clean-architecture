//
//  NetworkError.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case noInternetConnection
    case timeout
    case invalidResponse
    case decodingFailed(String)      // Carries description for Equatable conformance
    case serverError(statusCode: Int)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Showing cached data."
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingFailed(let msg):
            return "Failed to decode response: \(msg)"
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .unknown(let msg):
            return "Unexpected error: \(msg)"
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternetConnection, .noInternetConnection),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse):
            return true
        case (.decodingFailed(let a), .decodingFailed(let b)):   return a == b
        case (.serverError(let a), .serverError(let b)):         return a == b
        case (.unknown(let a), .unknown(let b)):                 return a == b
        default: return false
        }
    }
}


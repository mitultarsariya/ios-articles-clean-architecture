//
//  APIError.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation

struct APIError: Codable {
    let status: String?
    let code: String?
    let message: String?
}


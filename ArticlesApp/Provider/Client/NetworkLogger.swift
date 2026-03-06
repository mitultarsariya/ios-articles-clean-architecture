//
//  NetworkLogger.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation
import Alamofire

final class NetworkLogger: EventMonitor {

    let queue = DispatchQueue(label: "com.articlesapp.networklogger", qos: .utility)
    private let log = AppLogger.shared

    func requestDidFinish(_ request: Request) {
        let method  = request.request?.httpMethod  ?? "?"
        let url     = request.request?.url?.absoluteString ?? "unknown"
        log.debug("➡️  [\(method)] \(url)")
    }

    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        let url    = request.request?.url?.absoluteString ?? "unknown"
        let code   = response.response?.statusCode ?? 0
        let timing = String(format: "%.2fs", response.metrics?.taskInterval.duration ?? 0)

        switch response.result {
        case .success:
            log.info("✅ [\(code)] \(url) — \(timing)")
        case .failure(let error):
            log.error("❌ [\(code)] \(url) — \(error.localizedDescription) — \(timing)")
        }
    }

    func request(_ request: Request, didFailToCreateURLRequestWithError error: AFError) {
        log.error("🔥 URL Request creation failed: \(error.localizedDescription)")
    }
}


//
//  NetworkClient.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation
import Alamofire

// MARK: - Protocol
protocol NetworkClientProtocol {
    func request<T: Decodable>(
        endpoint: APIEndpoints,
        parameters: Parameters?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

// MARK: - Implementation
final class NetworkClient: NetworkClientProtocol {

    private let session: Session
    private let reachability: ReachabilityManagerProtocol
    private let log = AppLogger.shared

    init(reachability: ReachabilityManagerProtocol) {
        self.reachability = reachability

        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest  = APIConfig.timeoutInterval
        config.timeoutIntervalForResource = APIConfig.timeoutInterval * 2

        self.session = Session(
            configuration: config,
            eventMonitors: [NetworkLogger()]
        )
    }

    func request<T: Decodable>(
        endpoint: APIEndpoints,
        parameters: Parameters? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard reachability.isConnected else {
            log.warning("Request blocked — no connectivity")
            completion(.failure(.noInternetConnection))
            return
        }

        let url = APIConfig.baseURL + endpoint.path
        log.debug("Firing request → \(url)")

        session
            .request(url, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { [weak self] response in
                guard let self else { return }
                switch response.result {
                case .success(let value):
                    self.log.info("Decoded \(T.self) successfully")
                    completion(.success(value))
                case .failure(let error):
                    let mapped = self.map(error, statusCode: response.response?.statusCode)
                    completion(.failure(mapped))
                }
            }
    }

    // MARK: - Private
    private func map(_ error: AFError, statusCode: Int?) -> NetworkError {
        if let code = statusCode { return .serverError(statusCode: code) }

        let nsError = error.underlyingError as? NSError
        switch nsError?.code {
        case NSURLErrorTimedOut:              return .timeout
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost: return .noInternetConnection
        default: break
        }

        if case .responseSerializationFailed(let reason) = error,
           case .decodingFailed(let decodeError) = reason {
            return .decodingFailed(decodeError.localizedDescription)
        }

        return .unknown(error.localizedDescription)
    }
}


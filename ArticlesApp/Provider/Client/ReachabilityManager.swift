//
//  ReachabilityManager.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation
import Reachability


// MARK: - Protocol
protocol ReachabilityManagerProtocol: AnyObject {
    var isConnected: Bool { get }
    var onConnectionChanged: ((Bool) -> Void)? { get set }
    func startMonitoring()
    func stopMonitoring()
}

// MARK: - Implementation
final class ReachabilityManager: ReachabilityManagerProtocol {

    private let reachability: Reachability
    private let log = AppLogger.shared

    var onConnectionChanged: ((Bool) -> Void)?

    var isConnected: Bool {
        reachability.connection != .unavailable
    }

    /// Throws if Reachability cannot be initialised (e.g. simulator restrictions)
    init() throws {
        reachability = try Reachability()
    }

    func startMonitoring() {
        reachability.whenReachable = { [weak self] reachability in
            DispatchQueue.main.async {
                self?.log.info("🌐 Network reachable via \(reachability.connection)")
                self?.onConnectionChanged?(true)
            }
        }
        reachability.whenUnreachable = { [weak self] _ in
            DispatchQueue.main.async {
                self?.log.warning("📵 Network unreachable")
                self?.onConnectionChanged?(false)
            }
        }
        do {
            try reachability.startNotifier()
            log.info("Reachability monitoring started")
        } catch {
            log.error("Reachability start failed: \(error.localizedDescription)")
        }
    }

    func stopMonitoring() {
        reachability.stopNotifier()
        log.info("Reachability monitoring stopped")
    }
}


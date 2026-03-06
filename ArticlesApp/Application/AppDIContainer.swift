//
//  AppDIContainer.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit
import Swinject

/// Composition Root — all dependencies registered here.
final class AppDIContainer {

    static let shared = AppDIContainer()
    let container = Container()

    private init() {
        registerAll()
    }

    // MARK: - Master Registration
    private func registerAll() {
        registerInfrastructure()
        registerNetworking()
        registerProviders()
        registerManagers()
        registerViewControllers()
    }

    // ── Infrastructure ─────────────────────────────────────────
    private func registerInfrastructure() {
        container.register(ReachabilityManagerProtocol.self) { _ -> ReachabilityManagerProtocol in
            do {
                let mgr = try ReachabilityManager()
                mgr.startMonitoring()
                return mgr
            } catch {
                AppLogger.shared.error("ReachabilityManager init failed: \(error)")
                fatalError("Cannot init ReachabilityManager — unrecoverable")
            }
        }.inObjectScope(.container)   // Singleton

        container.register(CacheManagerProtocol.self) { _ in
            CacheManager()
        }.inObjectScope(.container)

        container.register(ImageLoaderProtocol.self) { _ in
            ImageLoader()
        }.inObjectScope(.container)
    }

    // ── Networking ─────────────────────────────────────────────
    private func registerNetworking() {
        container.register(NetworkClientProtocol.self) { r in
            NetworkClient(reachability: r.resolve(ReachabilityManagerProtocol.self)!)
        }.inObjectScope(.container)
    }

    // ── Providers ──────────────────────────────────────────────
    private func registerProviders() {
        container.register(ArticleProviderProtocol.self) { r in
            ArticleProvider(client: r.resolve(NetworkClientProtocol.self)!)
        }   // transient — created fresh per call
    }

    // ── Managers ───────────────────────────────────────────────
    private func registerManagers() {
        container.register(ArticleManagerProtocol.self) { r in
            ArticleManager(
                provider:     r.resolve(ArticleProviderProtocol.self)!,
                cache:        r.resolve(CacheManagerProtocol.self)!,
                reachability: r.resolve(ReachabilityManagerProtocol.self)!
            )
        }.inObjectScope(.container)
    }

    // ── ViewControllers ────────────────────────────────────────
    private func registerViewControllers() {
        container.register(ArticleListViewController.self) { r in
            let sb = UIStoryboard(name: AppConstants.Storyboard.main, bundle: nil)
            // swiftlint:disable:next force_cast
            let vc = sb.instantiateViewController(
                withIdentifier: AppConstants.Storyboard.articleListVC
            ) as! ArticleListViewController
            vc.articleManager   = r.resolve(ArticleManagerProtocol.self)!
            vc.imageLoader      = r.resolve(ImageLoaderProtocol.self)!
            vc.reachability     = r.resolve(ReachabilityManagerProtocol.self)!
            return vc
        }

        container.register(ArticleDetailViewController.self) { r in
            let sb = UIStoryboard(name: AppConstants.Storyboard.main, bundle: nil)
            // swiftlint:disable:next force_cast
            let vc = sb.instantiateViewController(
                withIdentifier: AppConstants.Storyboard.articleDetailVC
            ) as! ArticleDetailViewController
            vc.imageLoader = r.resolve(ImageLoaderProtocol.self)!
            
            return vc
        }
    }

    // MARK: - Resolve Helper
    func resolve<T>(_ type: T.Type) -> T? {
        container.resolve(type)
    }
}


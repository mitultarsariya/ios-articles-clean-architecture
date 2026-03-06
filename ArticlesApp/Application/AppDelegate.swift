//
//  AppDelegate.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit
import AlamofireNetworkActivityIndicator
import FTLinearActivityIndicator

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureNetworkIndicator()
        configureGlobalAppearance()
        AppLogger.shared.info("🚀 Application launched — env: \(Environment.current)")
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration",
                             sessionRole: connectingSceneSession.role)
    }

    // MARK: - Private
    private func configureNetworkIndicator() {
        UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
        NetworkActivityIndicatorManager.shared.isEnabled      = true
        NetworkActivityIndicatorManager.shared.startDelay     = 0.5
        NetworkActivityIndicatorManager.shared.completionDelay = 0.2
    }

    private func configureGlobalAppearance() {
        let teal = UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = teal
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor            = .white
    }
}


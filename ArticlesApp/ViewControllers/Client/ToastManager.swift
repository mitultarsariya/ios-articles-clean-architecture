//
//  ToastManager.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit
import Loaf

/// Centralised toast presentation
final class ToastManager {

    static func showOffline(in vc: UIViewController) {
        Loaf("You're offline. Showing cached data.",
             state: .custom(.init(backgroundColor: .systemOrange,
                                  icon: UIImage(systemName: "wifi.slash"))),
             location: .top,
             sender: vc).show(.short)
    }

    static func showError(_ message: String, in vc: UIViewController) {
        Loaf(message, state: .error, location: .top, sender: vc).show(.short)
    }

    static func showSuccess(_ message: String, in vc: UIViewController) {
        Loaf(message, state: .success, location: .top, sender: vc).show(.short)
    }

    static func showInfo(_ message: String, in vc: UIViewController) {
        Loaf(message, state: .info, location: .top, sender: vc).show(.short)
    }
}


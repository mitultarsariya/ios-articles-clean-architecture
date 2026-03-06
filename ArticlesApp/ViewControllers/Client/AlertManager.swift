//
//  AlertManager.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit

final class AlertManager {

    static func showError(
        title: String = "Error",
        message: String,
        in vc: UIViewController,
        onRetry: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        if let retry = onRetry {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in retry() })
        }
        vc.present(alert, animated: true)
    }
}


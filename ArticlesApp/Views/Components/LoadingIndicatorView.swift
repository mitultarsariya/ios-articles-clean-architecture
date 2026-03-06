//
//  LoadingIndicatorView.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit

final class LoadingIndicatorView: UIView {

    // MARK: - UI
    private let spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.color = UIColor(red: 0.10, green: 0.45, blue: 0.45, alpha: 1)
        v.hidesWhenStopped = true
        return v
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text          = "Loading articles…"
        l.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor     = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [spinner, messageLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis      = .vertical
        sv.alignment = .center
        sv.spacing   = 12
        return sv
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Visibility override
    override var isHidden: Bool {
        didSet {
            isHidden ? spinner.stopAnimating() : spinner.startAnimating()
        }
    }

    // MARK: - Private
    private func setup() {
        backgroundColor = UIColor.systemGroupedBackground
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40)
        ])
        spinner.startAnimating()
    }
}


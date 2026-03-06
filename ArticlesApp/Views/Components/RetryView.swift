//
//  RetryView.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit

final class RetryView: UIView {

    // MARK: - Public callback
    var onRetry: (() -> Void)?

    // MARK: - UI
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image       = UIImage(systemName: "wifi.slash")
        iv.tintColor   = UIColor(white: 0.4, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text          = "You're offline"
        l.font          = UIFont.boldSystemFont(ofSize: 18)
        l.textColor     = .label
        l.textAlignment = .center
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text          = "Please connect to the internet and try again."
        l.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor     = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private lazy var retryButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false

        var config                       = UIButton.Configuration.bordered()
        config.title                     = "Retry"
        config.image                     = UIImage(systemName: "arrow.clockwise")
        config.imagePlacement            = .leading
        config.imagePadding              = 6
        config.baseForegroundColor       = UIColor(red: 0.10, green: 0.45, blue: 0.45, alpha: 1)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.boldSystemFont(ofSize: 15)
            return out
        }
        b.configuration = config

        b.layer.cornerRadius = 20
        b.clipsToBounds      = true
        b.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return b
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [iconImageView, titleLabel, messageLabel, retryButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis      = .vertical
        sv.alignment = .center
        sv.spacing   = 14
        sv.setCustomSpacing(20, after: messageLabel)   // extra gap before button
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

    // MARK: - Public
    /// Call this before un-hiding to update the message text
    func configure(message: String) {
        messageLabel.text = message
    }

    // MARK: - Private
    private func setup() {
        backgroundColor = UIColor.systemGroupedBackground
        addSubview(stackView)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 72),
            iconImageView.heightAnchor.constraint(equalToConstant: 72),

            retryButton.widthAnchor.constraint(equalToConstant: 130),
            retryButton.heightAnchor.constraint(equalToConstant: 44),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}


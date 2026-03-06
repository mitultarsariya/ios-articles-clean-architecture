//
//  ArticleTableViewCell.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit
import Kingfisher

final class ArticleTableViewCell: UITableViewCell {

    
    // Fires when user taps the Read More button specifically
    var onReadMoreTapped: (() -> Void)?
    
    // MARK: - IBOutlets

    @IBOutlet private weak var cardView:              UIView!

    @IBOutlet private weak var articleImageView:      UIImageView!
    
    @IBOutlet private weak var titleLabel:            UILabel!

    @IBOutlet private weak var bottomRowStackView:    UIStackView!

    @IBOutlet private weak var leftGroupStackView:    UIStackView!

    @IBOutlet private weak var calendarIconImageView: UIImageView!
    @IBOutlet private weak var dateLabel:             UILabel!

    @IBOutlet private weak var readMoreButton:        UIButton!
    
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        applyCardStyle()
        applyImageStyle()
        applyTitleStyle()
        applyBottomRowStyle()
        applyReadMoreStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.kf.cancelDownloadTask()
        articleImageView.image = nil
        titleLabel.text        = nil
        dateLabel.text         = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Recompute shadow path after every layout pass
        // so it always matches the rendered cardView frame
        cardView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: AppConstants.UI.cardCornerRadius
        ).cgPath
    }

    // MARK: - Public Configure

    func configure(with article: Article, imageLoader: ImageLoaderProtocol) {
        titleLabel.text = article.title
        dateLabel.text  = article.formattedDate

        imageLoader.loadImage(
            from: article.validImageURL,
            into: articleImageView,
            placeholder: UIImage(systemName: "photo.fill")
        )
    }

    // MARK: - Card Style

    private func applyCardStyle() {
        selectionStyle              = .none
        backgroundColor             = .clear
        contentView.backgroundColor = .clear

        cardView.layer.cornerRadius  = AppConstants.UI.cardCornerRadius
        cardView.layer.masksToBounds = false   // must be false to show shadow

        cardView.layer.shadowColor   = UIColor.black.cgColor
        cardView.layer.shadowOpacity = AppConstants.UI.shadowOpacity
        cardView.layer.shadowOffset  = CGSize(width: 0, height: AppConstants.UI.shadowOffsetY)
        cardView.layer.shadowRadius  = AppConstants.UI.shadowRadius
    }

    // MARK: - Image Style

    private func applyImageStyle() {
        articleImageView.contentMode   = .scaleAspectFill
        articleImageView.clipsToBounds = true

        // Clip only the top two corners to follow the card's shape
        articleImageView.layer.cornerRadius  = AppConstants.UI.imageCornerRadius
        articleImageView.layer.maskedCorners = [
            .layerMinXMinYCorner,   // top-left
            .layerMaxXMinYCorner    // top-right
        ]

        // Placeholder background while image loads
        articleImageView.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }

    // MARK: - Title Style

    private func applyTitleStyle() {
        titleLabel.font          = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
    }

    // MARK: - Bottom Row Style

    private func applyBottomRowStyle() {
        // ── Outer HStack ──────────────────────────────────────────
        bottomRowStackView.axis         = .horizontal
        bottomRowStackView.alignment    = .center
        bottomRowStackView.distribution = .equalSpacing
        bottomRowStackView.spacing      = 0

        // ── Inner HStack (icon + date) ────────────────────────────
        leftGroupStackView.axis         = .horizontal
        leftGroupStackView.alignment    = .center
        leftGroupStackView.distribution = .fill
        leftGroupStackView.spacing      = 8

        // ── Calendar Icon ─────────────────────────────────────────
        calendarIconImageView.image       = UIImage(systemName: "calendar")
        calendarIconImageView.tintColor   = UIColor(white: 0.55, alpha: 1)
        calendarIconImageView.contentMode = .scaleAspectFit

        calendarIconImageView.setContentHuggingPriority(.required, for: .horizontal)
        calendarIconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // ── Date Label ────────────────────────────────────────────
        dateLabel.font          = UIFont.systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor     = UIColor(white: 0.55, alpha: 1)
        dateLabel.numberOfLines = 1

        // Allow date label to fill remaining left-group space
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    // MARK: - Read More Button Style

    private func applyReadMoreStyle() {

        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
    }

    @objc private func readMoreTapped() {
        onReadMoreTapped?()
    }
}

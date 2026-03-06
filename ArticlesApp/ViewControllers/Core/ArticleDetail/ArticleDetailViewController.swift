//
//  ArticleDetailViewController.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit
import Kingfisher

final class ArticleDetailViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var tealHeaderView:     UIView!
    @IBOutlet private weak var customNavView:      UIView!
    @IBOutlet private weak var backButton:         UIButton!
    @IBOutlet private weak var navTitleLabel:      UILabel!

    @IBOutlet private weak var articleTitleLabel:  UILabel!

    @IBOutlet private weak var clockIconImageView: UIImageView!
    @IBOutlet private weak var timeLabel:          UILabel!

    @IBOutlet private weak var scrollView:         UIScrollView!
    @IBOutlet private weak var imageWrapperView:   UIView!
    
    @IBOutlet private weak var articleImageView:   UIImageView!
    @IBOutlet private weak var bodyContentLabel:   UILabel!

    // MARK: - Injected Dependencies
    var article:     Article?
    var imageLoader: ImageLoaderProtocol!

    // MARK: - Private
    private let log = AppLogger.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        /// Hide system nav bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureImageView()
        populateContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Restore system nav bar for ArticleList screen
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configureImageView() {
       
        articleImageView.layer.cornerRadius = 12
        articleImageView.clipsToBounds      = true
        articleImageView.contentMode        = .scaleAspectFill
        
        imageWrapperView.backgroundColor        = .clear
        imageWrapperView.layer.masksToBounds    = false
        imageWrapperView.layer.cornerRadius     = 12
        imageWrapperView.layer.shadowColor      = UIColor.black.cgColor
        imageWrapperView.layer.shadowOpacity    = 0.18
        imageWrapperView.layer.shadowOffset     = CGSize(width: 0, height: 6)
        imageWrapperView.layer.shadowRadius     = 12
        
        imageWrapperView.layoutIfNeeded()
        imageWrapperView.layer.shadowPath = UIBezierPath(
            roundedRect: imageWrapperView.bounds,
            cornerRadius: 12
        ).cgPath
    }

    // MARK: - Populate Data Only

    private func populateContent() {
        guard let article else {
            log.warning("ArticleDetailVC: article not injected")
            return
        }

        // Title
        articleTitleLabel.text = article.title

        // Time
        let time = article.relativeTime.isEmpty
            ? article.formattedDate
            : article.relativeTime
        timeLabel.text = time

        // Image
        imageLoader.loadImage(
            from: article.validImageURL,
            into: articleImageView,
            placeholder: UIImage(systemName: "photo.fill")
        )

        // Body content with readable line height
        let body = article.content ?? article.description ?? "No content available."
        bodyContentLabel.attributedText = buildBodyText(cleanContent(body))

        log.info("ArticleDetail → populated: \(article.title.prefix(50))")
    }

    // MARK: - IBActions

    @IBAction private func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers

    private func buildBodyText(_ text: String) -> NSAttributedString {
        let paragraphStyle              = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.6
        paragraphStyle.paragraphSpacing   = 10

        return NSAttributedString(
            string: text,
            attributes: [
                .font:           UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    private func cleanContent(_ raw: String) -> String {
        // Strip API truncation marker e.g. "[+2889 chars]"
        guard let range = raw.range(
            of: #"\s*\[\+\d+ chars\]"#,
            options: .regularExpression
        ) else { return raw }
        return String(raw[..<range.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

//
//  ImageLoader.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit
import Kingfisher

// MARK: - Protocol
protocol ImageLoaderProtocol {
    func loadImage(from url: URL?, into imageView: UIImageView, placeholder: UIImage?)
    func prefetchImages(urls: [URL])
    func cancelPrefetching()
}

// MARK: - Implementation
final class ImageLoader: ImageLoaderProtocol {

    private var prefetcher: ImagePrefetcher?
    private let log = AppLogger.shared

    init() { configure() }

    // MARK: - Public
    func loadImage(
        from url: URL?,
        into imageView: UIImageView,
        placeholder: UIImage? = UIImage(systemName: "photo")
    ) {
        guard let url else {
            imageView.image = placeholder
            return
        }
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .backgroundDecode
            ]
        ) { [weak self] result in
            if case .failure(let err) = result {
                self?.log.warning("Image load failed [\(url.lastPathComponent)]: \(err.localizedDescription)")
            }
        }
    }

    func prefetchImages(urls: [URL]) {
        prefetcher?.stop()
        prefetcher = ImagePrefetcher(urls: urls) { [weak self] skipped, failed, completed in
            self?.log.debug("Prefetch done — ✅\(completed.count) ⏭\(skipped.count) ❌\(failed.count)")
        }
        prefetcher?.start()
    }

    func cancelPrefetching() {
        prefetcher?.stop()
        prefetcher = nil
    }

    // MARK: - Private
    private func configure() {
        let cache = KingfisherManager.shared.cache
        cache.memoryStorage.config.totalCostLimit = 50 * 1_024 * 1_024   // 50 MB RAM
        cache.diskStorage.config.sizeLimit        = 200 * 1_024 * 1_024  // 200 MB disk
        cache.diskStorage.config.expiration       = .days(7)
    }
}


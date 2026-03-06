//
//  ArticleListViewController.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import UIKit

final class ArticleListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Injected Dependencies
    var articleManager: ArticleManagerProtocol!
    var imageLoader:    ImageLoaderProtocol!
    var reachability:   ReachabilityManagerProtocol!

    // MARK: - Private
    private var articles: [Article] = []
    private let router = Router()
    private let log    = AppLogger.shared

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = UIColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
        rc.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return rc
    }()

    // Overlay views (programmatic reusable components)
    private lazy var loadingView: LoadingIndicatorView = {
        let v = LoadingIndicatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var emptyView: EmptyStateView = {
        let v = EmptyStateView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var retryView: RetryView = {
        let v = RetryView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - View State
    private var viewState: ArticleListViewState = .idle {
        didSet { applyState(viewState) }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        pinOverlayViews()
        observeReachability()
        loadArticles()
    }

    // MARK: - Configuration
    private func configureNavigationBar() {
        title = "Articles"
    }

    private func configureTableView() {
        tableView.delegate          = self
        tableView.dataSource        = self
        tableView.prefetchDataSource = self
        tableView.separatorStyle    = .none
        tableView.backgroundColor   = .systemGroupedBackground
        tableView.contentInset      = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.refreshControl    = refreshControl
        tableView.rowHeight         = UITableView.automaticDimension
        tableView.estimatedRowHeight = 340

        let nib = UINib(nibName: AppConstants.Xib.articleCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: AppConstants.Xib.articleCell)
    }

    private func pinOverlayViews() {
        // Explicitly typed as [UIView] so forEach gets full UIView API
        let overlays: [UIView] = [loadingView, emptyView, retryView]
        
        overlays.forEach { overlay in
            overlay.isHidden = true
            view.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // Wire retry callback after all views are pinned
        retryView.onRetry = { [weak self] in self?.loadArticles(forceRefresh: true) }
    }

    private func observeReachability() {
        reachability.onConnectionChanged = { [weak self] isConnected in
            guard let self else { return }
            if isConnected {
                self.log.info("↑ Connection restored — refreshing")
                self.loadArticles(forceRefresh: true)
            } else {
                ToastManager.showOffline(in: self)
            }
        }
    }

    // MARK: - Data
    private func loadArticles(forceRefresh: Bool = false) {
        if !forceRefresh { viewState = .loading }
        if !reachability.isConnected { ToastManager.showOffline(in: self) }

        articleManager.getArticles(forceRefresh: forceRefresh) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                switch result {
                case .success(let items):
                    self.articles = items
                    self.viewState = items.isEmpty ? .empty : .success(items)
                    self.prefetch(items)
                case .failure(let err):
                    self.viewState = .error(err.errorDescription ?? "An error occurred.")
                }
            }
        }
    }

    private func prefetch(_ articles: [Article]) {
        let urls = articles.compactMap(\.validImageURL)
        imageLoader.prefetchImages(urls: urls)
    }

    // MARK: - View State Rendering
    private func applyState(_ state: ArticleListViewState) {
        let overlays: [UIView] = [loadingView, emptyView, retryView]
        overlays.forEach { $0.isHidden = true }
        
        tableView.isHidden = false
        
        switch state {
        case .idle:
            break
            
        case .loading:
            tableView.isHidden    = true
            loadingView.isHidden  = false
            
        case .success:
            tableView.reloadData()
            
        case .empty:
            tableView.isHidden   = true
            emptyView.isHidden   = false
            
        case .error(let msg):
            tableView.isHidden  = true
            retryView.isHidden  = false
            retryView.configure(message: msg)
        }
    }

    // MARK: - Actions
    @objc private func didPullToRefresh() {
        loadArticles(forceRefresh: true)
    }

    // MARK: - Helpers
    private func makeOverlay<T: UIView>() -> T {
        let v = T()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
}

// MARK: - UITableViewDataSource
extension ArticleListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AppConstants.Xib.articleCell, for: indexPath
        ) as? ArticleTableViewCell else { return UITableViewCell() }

        let article = articles[indexPath.row]
        cell.configure(with: article, imageLoader: imageLoader)
        
        cell.onReadMoreTapped = { [weak self] in
            guard let self else { return }
            self.router.navigateToDetail(from: self, with: article)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ArticleListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        router.navigateToDetail(from: self, with: articles[indexPath.row])
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension ArticleListViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { articles[$0.row].validImageURL }
        imageLoader.prefetchImages(urls: urls)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // Kingfisher handles individual cancellation internally
    }
}


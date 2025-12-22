//
//  OrgReposViewController.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import SnapKit
import UIKit

final class OrgReposViewController: UIViewController {

    private let viewModel: OrgReposViewModel

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(
            RepositoryCell.self,
            forCellReuseIdentifier: RepositoryCell.reuseIdentifier
        )
        table.register(
            LoadingFooterCell.self,
            forCellReuseIdentifier: LoadingFooterCell.reuseIdentifier
        )
        table.separatorStyle = .none
        table.backgroundColor = .background
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = Spacing.Layout.estimatedRowHeight
        table.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Spacing.Space.xl,
            right: 0
        )
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .automatic
        return table
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(
            self,
            action: #selector(handleRefresh),
            for: .valueChanged
        )
        return refresh
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: OrgReposViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupDebugButton()
        viewModel.delegate = self
        viewModel.loadInitialRepositories()
    }

    private func setupDebugButton() {
        // just to test out when requests "failing"
        #if DEBUG
            let errorButton = UIBarButtonItem(
                title: "❌",
                style: .plain,
                target: self,
                action: #selector(triggerError)
            )
            errorButton.tintColor = .error
            navigationItem.rightBarButtonItem = errorButton
        #endif
    }

    @objc private func triggerError() {
        let errorState = ViewState.error(
            "Test Error: Unable to load repositories. Please check your connection and try again."
        )
        viewModel.delegate?.didChangeState(
            errorState,
            previousState: viewModel.state
        )
    }

    private func setupView() {
        title = "Square Repositories"
        view.backgroundColor = .background

        setupNavigationBar()

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        tableView.refreshControl = refreshControl
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(didTapClear)
        )

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .background
        appearance.shadowColor = .border
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.titleSmall,
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func handleRefresh() {
        viewModel.loadInitialRepositories()
    }

    @objc private func didTapClear() {
        viewModel.clearRepositories()
    }
}

extension OrgReposViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        switch viewModel.state {
        case .initial, .loading, .empty, .error:
            return 0
        case .refreshing(let repos), .loaded(let repos):
            return repos.count
        case .loadingMore(let repos):
            return repos.count + 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        switch viewModel.state {
        case .initial, .loading, .empty, .error:
            return UITableViewCell()

        case .refreshing(let repos), .loaded(let repos):
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: RepositoryCell.reuseIdentifier,
                    for: indexPath
                ) as? RepositoryCell
            else {
                return UITableViewCell()
            }

            let repository = repos[indexPath.row]
            cell.configure(with: repository, animated: false)
            return cell

        case .loadingMore(let repos):
            if indexPath.row < repos.count {
                guard
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: RepositoryCell.reuseIdentifier,
                        for: indexPath
                    ) as? RepositoryCell
                else {
                    return UITableViewCell()
                }

                let repository = repos[indexPath.row]
                cell.configure(with: repository, animated: false)
                return cell
            } else {
                guard
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: LoadingFooterCell.reuseIdentifier,
                        for: indexPath
                    ) as? LoadingFooterCell
                else {
                    return UITableViewCell()
                }
                return cell
            }
        }
    }
}

extension OrgReposViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if viewModel.shouldLoadMore(at: indexPath.row) {
            viewModel.loadNextPage()
        }
    }
}

extension OrgReposViewController: OrgReposViewModelDelegate {
    func didChangeState(_ state: ViewState, previousState: ViewState) {

        switch (previousState, state) {
        case (.initial, .loading):
            clearBackgroundView()
            showLoadingIndicator()

        case (.loaded, .refreshing), (.error, .loading):
            clearBackgroundView()

        case (.loading, .loaded(_)):
            clearBackgroundView()
            hideLoadingIndicator()
            refreshControl.endRefreshing()
            tableView.reloadData()

        case (.refreshing, .loaded):
            clearBackgroundView()
            refreshControl.endRefreshing()
            tableView.reloadData()

        case (.loaded(_), .loadingMore):
            break

        case (.loadingMore(let oldRepos), .loaded(let newRepos)):
            animateLoadMore(oldCount: oldRepos.count, newCount: newRepos.count)

        case (_, .error(let message)):
            clearBackgroundView()
            refreshControl.endRefreshing()
            showError(message: message)

        case (_, .empty):
            hideLoadingIndicator()
            refreshControl.endRefreshing()
            showEmptyState()
            tableView.reloadData()

        default:
            clearBackgroundView()
            refreshControl.endRefreshing()
            tableView.reloadData()
        }
    }

    private func clearBackgroundView() {
        tableView.backgroundView = nil
    }

    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }

    private func animateInitialLoad(repos: [Repository]) {
        tableView.reloadData()
    }

    private func animateLoadMore(oldCount: Int, newCount: Int) {
        let newIndexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: newIndexPaths, with: .fade)
        } completion: { _ in
            for indexPath in newIndexPaths.prefix(3) {
                if let cell = self.tableView.cellForRow(at: indexPath)
                    as? RepositoryCell,
                    let repo = self.viewModel.repository(at: indexPath.row)
                {
                    cell.configure(with: repo, animated: true)
                }
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Retry", style: .default) { _ in
                self.viewModel.loadInitialRepositories()
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func showEmptyState() {
        let emptyView = EmptyStateView(
            icon: "🌞",
            title: "No Repositories",
            message: "Pull to refresh or try again later"
        )
        tableView.backgroundView = emptyView
    }
}

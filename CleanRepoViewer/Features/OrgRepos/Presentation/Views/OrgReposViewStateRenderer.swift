//
//  OrgReposViewStateRenderer.swift
//  CleanRepoViewer
//
//  Created by Miksa on 23.12.25.
//

import UIKit

final class OrgReposViewStateRenderer {

    private weak var tableView: UITableView?
    private weak var refreshControl: UIRefreshControl?
    private weak var loadingIndicator: UIActivityIndicatorView?

    init(
        tableView: UITableView,
        refreshControl: UIRefreshControl,
        loadingIndicator: UIActivityIndicatorView
    ) {
        self.tableView = tableView
        self.refreshControl = refreshControl
        self.loadingIndicator = loadingIndicator
    }

    func render(
        state: ViewState,
        previousState: ViewState,
        hasData: Bool,
        showErrorAlert: (String) -> Void
    ) {
        guard let tableView else { return }

        switch (previousState, state) {
        case (_, .loading):
            clearBackgroundView()
            showLoadingIndicator()
            tableView.reloadData()

        case (.loaded, .refreshing):
            clearBackgroundView()

        case (.loading, .loaded(let repos)):
            clearBackgroundView()
            hideLoadingIndicator()
            refreshControl?.endRefreshing()
            animateInitialLoad(repos: repos)

        case (.refreshing, .loaded):
            clearBackgroundView()
            refreshControl?.endRefreshing()
            tableView.reloadData()

        case (.loaded(_), .loadingMore):
            break

        case (.loadingMore(let oldRepos), .loaded(let newRepos)):
            animateLoadMore(oldCount: oldRepos.count, newCount: newRepos.count)

        case (_, .error(let message)):
            hideLoadingIndicator()
            refreshControl?.endRefreshing()

            if !hasData {
                showErrorState(message: message)
            } else {
                clearBackgroundView()
            }

            tableView.reloadData()
            showErrorAlert(message)

        case (_, .empty):
            hideLoadingIndicator()
            refreshControl?.endRefreshing()
            showEmptyState()
            tableView.reloadData()

        default:
            clearBackgroundView()
            refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }

    // MARK: - Private

    private func clearBackgroundView() {
        tableView?.backgroundView = nil
    }

    private func showLoadingIndicator() {
        loadingIndicator?.startAnimating()
    }

    private func hideLoadingIndicator() {
        loadingIndicator?.stopAnimating()
    }

    private func animateInitialLoad(repos: [Repository]) {
        guard let tableView else { return }
        let indexPaths = (0..<repos.count).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }

    private func animateLoadMore(oldCount: Int, newCount: Int) {
        guard let tableView else { return }
        let newIndexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: newIndexPaths, with: .fade)
        }
    }

    private func showErrorState(message: String) {
        let errorView = EmptyStateView(
            icon: "⚠️",
            title: "Couldn't load repositories",
            message: message
        )
        tableView?.backgroundView = errorView
    }

    private func showEmptyState() {
        let emptyView = EmptyStateView(
            icon: "🌞",
            title: "No Repositories",
            message: "Pull to refresh or try again later"
        )
        tableView?.backgroundView = emptyView
    }
}

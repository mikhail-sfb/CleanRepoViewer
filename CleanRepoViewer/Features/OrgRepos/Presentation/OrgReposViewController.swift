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

    private lazy var stateRenderer = OrgReposViewStateRenderer(
        tableView: tableView,
        refreshControl: refreshControl,
        loadingIndicator: loadingIndicator
    )

    private lazy var alertPresenter = OrgReposAlertPresenter(presenter: self)

    private lazy var tableView: UITableView = {
        let table = OrgReposTableViewFactory.makeTableView()
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
        viewModel.simulateError()
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
            make.edges.equalTo(view.safeAreaLayoutGuide)
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
        return viewModel.displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard indexPath.row < viewModel.displayItems.count else {
            return UITableViewCell()
        }

        let item = viewModel.displayItems[indexPath.row]

        switch item {
        case .repository(let repository):
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: RepositoryCell.reuseIdentifier,
                    for: indexPath
                ) as? RepositoryCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: repository)
            return cell

        case .loading:
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

extension OrgReposViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard indexPath.row < viewModel.displayItems.count else { return }
        guard case .repository = viewModel.displayItems[indexPath.row] else {
            return
        }

        if viewModel.shouldLoadMore(at: indexPath.row) {
            viewModel.loadNextPage()
        }
    }
}

extension OrgReposViewController: OrgReposViewModelDelegate {
    func didChangeState(_ state: ViewState, previousState: ViewState) {
        stateRenderer.render(
            state: state,
            previousState: previousState,
            hasData: viewModel.numberOfRepositories > 0,
            showErrorAlert: { [weak self] message in
                guard let self else { return }
                self.alertPresenter.showError(message: message) {
                    self.viewModel.loadInitialRepositories()
                }
            }
        )
    }
}

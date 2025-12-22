//
//  OrgReposViewModel.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

// We have only didChangeState, no need to think on lifecycle of subs
protocol OrgReposViewModelDelegate: AnyObject {
    func didChangeState(_ state: ViewState, previousState: ViewState)
}

final class OrgReposViewModel {

    weak var delegate: OrgReposViewModelDelegate?

    private let fetchRepositoriesUseCase: FetchRepositoriesUseCase
    private let perPage: Int

    private(set) var state: ViewState = .initial {
        didSet {
            if state != oldValue {
                delegate?.didChangeState(state, previousState: oldValue)
            }
        }
    }

    private var currentPage = 0
    private var hasMorePages = true
    private var fetchTask: Task<Void, Never>?

    init(fetchRepositoriesUseCase: FetchRepositoriesUseCase, pageSize: Int = 30)
    {
        self.fetchRepositoriesUseCase = fetchRepositoriesUseCase
        self.perPage = pageSize
    }

    deinit {
        fetchTask?.cancel()
    }

    var numberOfRepositories: Int {
        return state.repositories.count
    }

    func loadInitialRepositories() {
        currentPage = 0
        hasMorePages = true

        let currentRepos = state.repositories
        if currentRepos.isEmpty {
            state = .loading
        } else {
            state = .refreshing(currentRepos)
        }

        fetchPage(isInitial: true)
    }

    func loadNextPage() {
        guard !state.isLoading && hasMorePages else { return }

        let currentRepos = state.repositories
        state = .loadingMore(currentRepos)

        fetchPage(isInitial: false)
    }

    func clearRepositories() {
        currentPage = 0
        hasMorePages = true
        state = .empty
    }

    private func fetchPage(isInitial: Bool) {
        fetchTask?.cancel()

        let nextPage = currentPage + 1
        let input = FetchRepositoriesInput(page: nextPage, perPage: perPage)

        fetchTask = Task { @MainActor in
            do {
                let page = try await fetchRepositoriesUseCase.execute(
                    input: input
                )

                guard !Task.isCancelled else { return }

                self.currentPage = page.currentPage
                self.hasMorePages = page.hasNextPage

                var allRepositories = isInitial ? [] : self.state.repositories
                allRepositories.append(contentsOf: page.repositories)

                if allRepositories.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .loaded(allRepositories)
                }
            } catch {
                guard !Task.isCancelled else { return }
                self.state = .error(error.localizedDescription)
            }
        }
    }

    enum DisplayItem: Hashable {
        case repository(Repository)
        case loading
    }

    var displayItems: [DisplayItem] {
        switch state {
        case .initial, .loading, .empty, .error:
            return []
        case .refreshing(let repos), .loaded(let repos):
            return repos.map { .repository($0) }
        case .loadingMore(let repos):
            return repos.map { .repository($0) } + [.loading]
        }
    }

    func shouldLoadMore(at index: Int) -> Bool {
        let repos = state.repositories
        return index >= repos.count - 5 && hasMorePages && !state.isLoading
    }

    #if DEBUG
        func simulateError() {
            let debugError = NetworkError.serverError(
                statusCode: 500
            )
            handleError(debugError)
        }

        private func handleError(_ error: NetworkError) {
            state = .error(error.localizedDescription)
        }
    #endif
}

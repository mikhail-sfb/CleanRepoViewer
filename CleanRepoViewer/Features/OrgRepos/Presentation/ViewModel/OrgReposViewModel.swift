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
    private let perPage = 30

    private(set) var state: ViewState = .initial {
        didSet {
            if state != oldValue {
                delegate?.didChangeState(state, previousState: oldValue)
            }
        }
    }

    private var currentPage = 0
    private var hasMorePages = true

    init(fetchRepositoriesUseCase: FetchRepositoriesUseCase) {
        self.fetchRepositoriesUseCase = fetchRepositoriesUseCase
    }

    var numberOfRepositories: Int {
        return state.repositories.count
    }

    func repository(at index: Int) -> Repository? {
        let repos = state.repositories
        guard index >= 0 && index < repos.count else { return nil }
        return repos[index]
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

    /// Clears current list and shows the empty state.
    /// Useful for debugging UI states (e.g. after an error) and to force a pull-to-refresh.
    func clearRepositories() {
        currentPage = 0
        hasMorePages = true
        state = .empty
    }

    private func fetchPage(isInitial: Bool) {
        let nextPage = currentPage + 1
        let input = FetchRepositoriesInput(page: nextPage, perPage: perPage)

        Task { @MainActor in
            do {
                let page = try await fetchRepositoriesUseCase.execute(
                    input: input
                )

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
                if let networkError = error as? NetworkError {
                    self.state = .error(networkError.localizedDescription)
                } else {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func shouldLoadMore(at index: Int) -> Bool {
        let repos = state.repositories
        return index >= repos.count - 5 && hasMorePages && !state.isLoading
    }
}

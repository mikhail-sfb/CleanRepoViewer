//
//  ViewState.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

enum ViewState: Equatable {
    case initial
    case loading
    case refreshing([Repository])
    case loaded([Repository])
    case loadingMore([Repository])
    case empty
    case error(String)

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
            (.loading, .loading),
            (.empty, .empty):
            return true
        case (.refreshing(let lhsRepos), .refreshing(let rhsRepos)),
            (.loaded(let lhsRepos), .loaded(let rhsRepos)),
            (.loadingMore(let lhsRepos), .loadingMore(let rhsRepos)):
            return lhsRepos.map(\.id) == rhsRepos.map(\.id)
        case (.error(let lhsMsg), .error(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }

    var repositories: [Repository] {
        switch self {
        case .refreshing(let repos), .loaded(let repos),
            .loadingMore(let repos):
            return repos
        default:
            return []
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading, .refreshing, .loadingMore:
            return true
        default:
            return false
        }
    }
}

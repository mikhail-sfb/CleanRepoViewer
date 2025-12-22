//
//  OrgReposDataSource.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

final class OrgReposDataSource: BaseDataSource {

    let networkService: NetworkServicing

    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }

    func fetchRepositories(page: Int, perPage: Int) async throws
        -> [RepositoryDTO]
    {
        let endpoint = APIEndpoint.squareRepositories(
            page: page,
            perPage: perPage
        )

        return try await networkService.request(endpoint)
    }
}

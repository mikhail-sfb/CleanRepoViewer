//
//  OrgReposRepositoryImplementation.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

final class OrgReposRepositoryImplementation: OrgReposRepository {
    
    private let dataSource: OrgReposDataSource
    
    init(dataSource: OrgReposDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchRepositories(page: Int, perPage: Int) async throws -> RepositoriesPage {
        let dtos = try await dataSource.fetchRepositories(page: page, perPage: perPage)
        let repositories = dtos.map { $0.toDomain() }
        
        let hasNextPage = repositories.count >= perPage
        
        return RepositoriesPage(
            repositories: repositories,
            hasNextPage: hasNextPage,
            currentPage: page
        )
    }
}

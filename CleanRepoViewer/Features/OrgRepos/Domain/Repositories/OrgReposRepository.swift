//
//  OrgReposRepository.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

protocol OrgReposRepository {
    func fetchRepositories(page: Int, perPage: Int) async throws -> RepositoriesPage
}

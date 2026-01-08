//
//  FetchRepositoriesUseCase.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

struct FetchRepositoriesInput {
    let page: Int
    let perPage: Int
}

final class FetchRepositoriesUseCase: UseCase {
    typealias Input = FetchRepositoriesInput
    typealias Output = RepositoriesPage
    
    private let repository: OrgReposRepository
    
    init(repository: OrgReposRepository) {
        self.repository = repository
    }
    
    func execute(input: FetchRepositoriesInput) async throws -> RepositoriesPage {
        return try await repository.fetchRepositories(page: input.page, perPage: input.perPage)
    }
}

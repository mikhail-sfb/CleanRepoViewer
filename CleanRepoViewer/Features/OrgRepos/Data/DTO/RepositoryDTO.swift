//
//  RepositoryDTO.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

struct RepositoryDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    
    func toDomain() -> Repository {
        return Repository(
            id: id,
            name: name,
            description: description
        )
    }
}

//
//  BaseDataSource.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

protocol BaseDataSource {
    var networkService: NetworkServicing { get }
}

extension BaseDataSource {

    func performRequest<T: Decodable>(
        _ endpoint: APIEndpoint
    ) async throws -> T {
        return try await networkService.request(endpoint)
    }
}

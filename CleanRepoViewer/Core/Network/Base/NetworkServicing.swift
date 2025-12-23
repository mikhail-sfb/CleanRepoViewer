//
//  NetworkServicing.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

protocol NetworkServicing {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

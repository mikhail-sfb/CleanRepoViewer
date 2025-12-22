//
//  MockNetworkService.swift
//  CleanRepoViewerTests
//
//  Created by Miksa on 22.12.25.
//

import Foundation

@testable import CleanRepoViewer

final class MockNetworkService: NetworkServicing {

    struct StubKey: Hashable {
        let endpointURL: String
        let responseType: ObjectIdentifier
    }

    var requestCallCount = 0
    var requestedEndpoints: [APIEndpoint] = []

    private var stubs: [StubKey: Result<Data, Error>] = [:]

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        requestCallCount += 1
        requestedEndpoints.append(endpoint)

        guard let urlString = endpoint.url?.absoluteString else {
            throw NetworkError.invalidURL
        }

        let key = StubKey(
            endpointURL: urlString,
            responseType: ObjectIdentifier(T.self)
        )

        guard let stub = stubs[key] else {
            throw NetworkError.unknown(
                "No stub configured for \(urlString) and type \(T.self)"
            )
        }

        switch stub {
        case .success(let data):
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }
        case .failure(let error):
            throw error
        }
    }

    func stub(endpoint: APIEndpoint, data: Data, responseType: Decodable.Type) {
        guard let urlString = endpoint.url?.absoluteString else { return }
        let key = StubKey(
            endpointURL: urlString,
            responseType: ObjectIdentifier(responseType)
        )
        stubs[key] = .success(data)
    }

    func stub(endpoint: APIEndpoint, error: Error, responseType: Decodable.Type)
    {
        guard let urlString = endpoint.url?.absoluteString else { return }
        let key = StubKey(
            endpointURL: urlString,
            responseType: ObjectIdentifier(responseType)
        )
        stubs[key] = .failure(error)
    }

    func stubJSON(
        endpoint: APIEndpoint,
        json: String,
        responseType: Decodable.Type
    ) {
        stub(
            endpoint: endpoint,
            data: Data(json.utf8),
            responseType: responseType
        )
    }

    func reset() {
        requestCallCount = 0
        requestedEndpoints = []
        stubs = [:]
    }
}

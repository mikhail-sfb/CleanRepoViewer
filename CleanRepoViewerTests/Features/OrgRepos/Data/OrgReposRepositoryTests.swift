//
//  OrgReposRepositoryTests.swift
//  CleanRepoViewerTests
//
//  Created by Miksa on 22.12.25.
//

import XCTest

@testable import CleanRepoViewer

private func makeRepositoriesDTOJSON(_ dtos: [RepositoryDTO]) throws -> Data {
    let jsonArray: [[String: Any?]] = dtos.map {
        [
            "id": $0.id,
            "name": $0.name,
            "description": $0.description
        ]
    }

    let normalized: [[String: Any]] = jsonArray.map { dict in
        var out: [String: Any] = [:]
        for (k, v) in dict {
            out[k] = v ?? NSNull()
        }
        return out
    }

    return try JSONSerialization.data(withJSONObject: normalized, options: [])
}


@MainActor
final class OrgReposRepositoryTests: XCTestCase {

    var sut: OrgReposRepositoryImplementation!
    var mockNetworkService: MockNetworkService!
    var dataSource: OrgReposDataSource!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        dataSource = OrgReposDataSource(networkService: mockNetworkService)
        sut = OrgReposRepositoryImplementation(dataSource: dataSource)
    }

    override func tearDown() {
        sut = nil
        dataSource = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func test_fetchRepositories_success_returnsRepositoriesPage() async throws {
        let stubDTOs = [
            RepositoryDTO(id: 1, name: "Repo1", description: "Description1"),
            RepositoryDTO(id: 2, name: "Repo2", description: nil),
        ]
        let endpoint = APIEndpoint.squareRepositories(page: 1, perPage: 2)
        let data = try makeRepositoriesDTOJSON(stubDTOs)
        mockNetworkService.stub(endpoint: endpoint, data: data, responseType: [RepositoryDTO].self)

        let result = try await sut.fetchRepositories(page: 1, perPage: 2)

        XCTAssertEqual(result.repositories.count, 2)
        XCTAssertEqual(result.repositories[0].id, 1)
        XCTAssertEqual(result.repositories[0].name, "Repo1")
        XCTAssertEqual(result.repositories[0].description, "Description1")
        XCTAssertEqual(result.repositories[1].name, "Repo2")
        XCTAssertNil(result.repositories[1].description)
        XCTAssertEqual(result.currentPage, 1)
    }

    func test_fetchRepositories_fullPage_hasNextPageIsTrue() async throws {
        let stubDTOs = Array(0..<30).map {
            RepositoryDTO(id: $0, name: "Repo\($0)", description: nil)
        }
        let endpoint = APIEndpoint.squareRepositories(page: 1, perPage: 30)
        let data = try makeRepositoriesDTOJSON(stubDTOs)
        mockNetworkService.stub(endpoint: endpoint, data: data, responseType: [RepositoryDTO].self)

        let result = try await sut.fetchRepositories(page: 1, perPage: 30)

        XCTAssertTrue(result.hasNextPage)
    }

    func test_fetchRepositories_partialPage_hasNextPageIsFalse() async throws {
        let stubDTOs = Array(0..<10).map {
            RepositoryDTO(id: $0, name: "Repo\($0)", description: nil)
        }
        let endpoint = APIEndpoint.squareRepositories(page: 2, perPage: 30)
        let data = try makeRepositoriesDTOJSON(stubDTOs)
        mockNetworkService.stub(endpoint: endpoint, data: data, responseType: [RepositoryDTO].self)

        let result = try await sut.fetchRepositories(page: 2, perPage: 30)

        XCTAssertFalse(result.hasNextPage)
    }

    func test_fetchRepositories_networkError_throwsError() async {
        let expectedError = NetworkError.notFound
        let endpoint = APIEndpoint.squareRepositories(page: 1, perPage: 30)
        mockNetworkService.stub(endpoint: endpoint, error: expectedError, responseType: [RepositoryDTO].self)

        do {
            _ = try await sut.fetchRepositories(page: 1, perPage: 30)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func test_fetchRepositories_callsNetworkServiceOnce() async throws {
        let stubDTOs = [RepositoryDTO(id: 1, name: "Repo1", description: nil)]
        let endpoint = APIEndpoint.squareRepositories(page: 1, perPage: 30)
        let data = try makeRepositoriesDTOJSON(stubDTOs)
        mockNetworkService.stub(endpoint: endpoint, data: data, responseType: [RepositoryDTO].self)

        _ = try await sut.fetchRepositories(page: 1, perPage: 30)

        XCTAssertEqual(mockNetworkService.requestCallCount, 1)
    }
}

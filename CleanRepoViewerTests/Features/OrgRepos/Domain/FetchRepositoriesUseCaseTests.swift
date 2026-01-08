//
//  FetchRepositoriesUseCaseTests.swift
//  CleanRepoViewerTests
//
//  Created by Miksa on 22.12.25.
//

import XCTest

@testable import CleanRepoViewer

final class MockOrgReposRepository: OrgReposRepository {
    var fetchCallCount = 0
    var stubbedResult: Result<RepositoriesPage, Error>?
    var capturedPage: Int?
    var capturedPerPage: Int?

    func fetchRepositories(page: Int, perPage: Int) async throws
        -> RepositoriesPage
    {
        fetchCallCount += 1
        capturedPage = page
        capturedPerPage = perPage

        guard let result = stubbedResult else {
            throw NetworkError.unknown("No stub configured")
        }

        switch result {
        case .success(let page):
            return page
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
final class FetchRepositoriesUseCaseTests: XCTestCase {

    var sut: FetchRepositoriesUseCase!
    var mockRepository: MockOrgReposRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockOrgReposRepository()
        sut = FetchRepositoriesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_execute_success_returnsRepositoriesPage() async throws {
        let stubRepos = [
            Repository(id: 1, name: "Test", description: "Description")
        ]
        let stubPage = RepositoriesPage(
            repositories: stubRepos,
            hasNextPage: true,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(stubPage)

        let input = FetchRepositoriesInput(page: 1, perPage: 30)
        let result = try await sut.execute(input: input)

        XCTAssertEqual(result.repositories.count, 1)
        XCTAssertEqual(result.repositories[0].name, "Test")
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertTrue(result.hasNextPage)
    }

    func test_execute_passesCorrectParametersToRepository() async throws {
        let stubPage = RepositoriesPage(
            repositories: [],
            hasNextPage: false,
            currentPage: 2
        )
        mockRepository.stubbedResult = .success(stubPage)

        let input = FetchRepositoriesInput(page: 2, perPage: 50)
        _ = try await sut.execute(input: input)

        XCTAssertEqual(mockRepository.capturedPage, 2)
        XCTAssertEqual(mockRepository.capturedPerPage, 50)
    }

    func test_execute_repositoryThrowsError_propagatesError() async {
        let expectedError = NetworkError.rateLimitExceeded
        mockRepository.stubbedResult = .failure(expectedError)

        let input = FetchRepositoriesInput(page: 1, perPage: 30)

        do {
            _ = try await sut.execute(input: input)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func test_execute_callsRepositoryOnce() async throws {
        let stubPage = RepositoriesPage(
            repositories: [],
            hasNextPage: false,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(stubPage)

        let input = FetchRepositoriesInput(page: 1, perPage: 30)
        _ = try await sut.execute(input: input)

        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }
}

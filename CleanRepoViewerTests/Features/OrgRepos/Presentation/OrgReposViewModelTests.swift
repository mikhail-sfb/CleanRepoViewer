//
//  OrgReposViewModelTests.swift
//  CleanRepoViewerTests
//
//  Created by Miksa on 22.12.25.
//

import XCTest

@testable import CleanRepoViewer

@MainActor
final class MockOrgReposViewModelDelegate: OrgReposViewModelDelegate {
    var stateChanges: [(new: ViewState, previous: ViewState)] = []
    var onStateChange: ((ViewState, ViewState) -> Void)?

    func didChangeState(_ state: ViewState, previousState: ViewState) {
        stateChanges.append((new: state, previous: previousState))
        onStateChange?(state, previousState)
    }
}

@MainActor
final class OrgReposViewModelTests: XCTestCase {

    var sut: OrgReposViewModel!
    var mockRepository: MockOrgReposRepository!
    var mockDelegate: MockOrgReposViewModelDelegate!
    var useCase: FetchRepositoriesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockOrgReposRepository()
        useCase = FetchRepositoriesUseCase(repository: mockRepository)
        sut = OrgReposViewModel(fetchRepositoriesUseCase: useCase)
        mockDelegate = MockOrgReposViewModelDelegate()
        sut.delegate = mockDelegate
    }

    override func tearDown() {
        sut = nil
        useCase = nil
        mockRepository = nil
        mockDelegate = nil
        super.tearDown()
    }

    func test_initialState_isInitial() {
        XCTAssertEqual(sut.state, .initial)
    }

    func test_loadInitialRepositories_transitionsToLoading() {
        sut.loadInitialRepositories()

        XCTAssertEqual(sut.state, .loading)
    }

    func test_loadInitialRepositories_success_transitionsToLoaded() async throws
    {
        let stubRepos = [Repository(id: 1, name: "Test", description: nil)]
        let stubPage = RepositoriesPage(
            repositories: stubRepos,
            hasNextPage: true,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(stubPage)

        let exp = expectation(description: "Wait for loaded")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { exp.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let repos) = sut.state else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(repos.count, 1)
        XCTAssertEqual(repos[0].name, "Test")
    }

    func test_loadInitialRepositories_whenAlreadyLoaded_transitionsToRefreshingWithExistingRepos() async throws {
        let existingRepos = [
            Repository(id: 1, name: "Existing", description: nil)
        ]
        sut = OrgReposViewModel(fetchRepositoriesUseCase: useCase)
        sut.delegate = mockDelegate

        let firstPage = RepositoriesPage(
            repositories: existingRepos,
            hasNextPage: false,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(firstPage)

        let loaded = expectation(description: "Wait for loaded")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { loaded.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [loaded], timeout: 1.0)

        sut.loadInitialRepositories()

        guard case .refreshing(let repos) = sut.state else {
            XCTFail("Expected refreshing state")
            return
        }

        XCTAssertEqual(repos.map(\.id), existingRepos.map(\.id))
    }

    func test_loadNextPage_appendsRepositories() async throws {
        let firstBatch = [Repository(id: 1, name: "First", description: nil)]
        let firstPage = RepositoriesPage(
            repositories: firstBatch,
            hasNextPage: true,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(firstPage)

        let loaded1 = expectation(description: "Loaded first page")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { loaded1.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [loaded1], timeout: 1.0)

        let secondBatch = [Repository(id: 2, name: "Second", description: nil)]
        let secondPage = RepositoriesPage(
            repositories: secondBatch,
            hasNextPage: false,
            currentPage: 2
        )
        mockRepository.stubbedResult = .success(secondPage)

        let loaded2 = expectation(description: "Loaded second page")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { loaded2.fulfill() }
        }

        sut.loadNextPage()
        await fulfillment(of: [loaded2], timeout: 1.0)

        guard case .loaded(let repos) = sut.state else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(repos.count, 2)
        XCTAssertEqual(repos[0].name, "First")
        XCTAssertEqual(repos[1].name, "Second")
    }

    func test_loadRepositories_error_transitionsToErrorState() async throws {
        mockRepository.stubbedResult = .failure(NetworkError.notFound)

        let exp = expectation(description: "Wait for error")
        mockDelegate.onStateChange = { new, _ in
            if case .error = new { exp.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .error(let message) = sut.state else {
            XCTFail("Expected error state")
            return
        }

        XCTAssertFalse(message.isEmpty)
    }

    func test_numberOfRepositories_returnsCorrectCount() async throws {
        let stubRepos = [
            Repository(id: 1, name: "Repo1", description: nil),
            Repository(id: 2, name: "Repo2", description: nil),
        ]
        let stubPage = RepositoriesPage(
            repositories: stubRepos,
            hasNextPage: false,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(stubPage)

        let exp = expectation(description: "Wait for loaded")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { exp.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(sut.numberOfRepositories, 2)
    }

    func test_repositoryAtIndex_returnsCorrectRepository() async throws {
        let stubRepos = [
            Repository(id: 42, name: "TestRepo", description: "TestDesc")
        ]
        let stubPage = RepositoriesPage(
            repositories: stubRepos,
            hasNextPage: false,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(stubPage)

        let exp = expectation(description: "Wait for loaded")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { exp.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let repos) = sut.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(repos.first?.id, 42)
        XCTAssertEqual(repos.first?.name, "TestRepo")
        XCTAssertEqual(repos.first?.description, "TestDesc")
    }

    func test_shouldLoadMore_returnsTrueWhenNearEnd() async throws {
        let stubRepos = Array(0..<30).map {
            Repository(id: $0, name: "Repo\($0)", description: nil)
        }
        let stubPage = RepositoriesPage(
            repositories: stubRepos,
            hasNextPage: true,
            currentPage: 1
        )
        mockRepository.stubbedResult = .success(stubPage)

        let exp = expectation(description: "Wait for loaded")
        mockDelegate.onStateChange = { new, _ in
            if case .loaded = new { exp.fulfill() }
        }

        sut.loadInitialRepositories()
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertTrue(sut.shouldLoadMore(at: 25))
        XCTAssertFalse(sut.shouldLoadMore(at: 10))
    }
}

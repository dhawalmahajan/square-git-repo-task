//
//  FetchReposUseCaseTests.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import XCTest

@testable import Square

final class FetchReposUseCaseTests: XCTestCase {
  //MARK: properties
  private var mockRepo: MockRepoRepository! = nil
  private var useCase: FetchReposUseCase! = nil
  //MARK: test lifecycle
  override func setUp() {
    super.setUp()
    mockRepo = MockRepoRepository()
    mockRepo.mockRepos = RepoStub.repoList
    useCase = FetchReposUseCase(repository: mockRepo)
  }

  override func tearDown() {
    useCase = nil
    mockRepo = nil
    super.tearDown()
  }

  //MARK: Test cases
  func test_whenRepositoryReturnsRepos_thenExecuteDeliversRepos() {

    let expectation = expectation(description: "usecase")

    useCase.execute(page: 1, perPage: 20) { result in
      switch result {
      case .success(let repos):
        XCTAssertEqual(repos.count, 2)
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: 2)
  }
  func test_whenRepositoryReturnsRepos_thenRepoDataIsUnmodified() {
    mockRepo.mockRepos = RepoStub.repoList

    let expectation = expectation(description: "UseCase should not mutate repo data")

    useCase.execute(page: 1, perPage: 20) { result in
      if case .success(let repos) = result {
        XCTAssertEqual(repos.first?.name, RepoStub.repoList.first?.name)
        XCTAssertEqual(repos.last?.name, RepoStub.repoList.last?.name)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 2)
  }

  // MARK: - Empty

  func test_whenRepositoryReturnsEmptyList_thenExecuteDeliversEmptyList() {
    mockRepo.mockRepos = []

    let expectation = expectation(description: "UseCase should forward empty list as success")

    useCase.execute(page: 1, perPage: 20) { result in
      switch result {
      case .success(let repos):
        XCTAssertTrue(repos.isEmpty, "Expected empty repo list")
        expectation.fulfill()
      case .failure:
        XCTFail("Empty list should be success, not failure")
      }
    }

    wait(for: [expectation], timeout: 2)
  }

  // MARK: - Failure

  func test_whenRepositoryFails_thenExecuteDeliversError() {
    mockRepo.shouldFail = true

    let expectation = expectation(description: "UseCase should forward repository error")

    useCase.execute(page: 1, perPage: 20) { result in
      switch result {
      case .success:
        XCTFail("Expected failure but got success")
      case .failure(let error):
        XCTAssertNotNil(error, "Expected a non-nil error")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 2)
  }

  func test_whenRepositoryFails_thenErrorIsNetworkError() {
    mockRepo.shouldFail = true

    let expectation = expectation(description: "UseCase should forward URLError from repository")

    useCase.execute(page: 1, perPage: 20) { result in
      if case .failure(let error) = result {
        XCTAssertTrue(error is URLError, "Expected URLError but got \(type(of: error))")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 2)
  }

  // MARK: - Multiple Calls

  func test_whenExecuteCalledMultipleTimes_thenEachCallDeliversResult() {
    mockRepo.mockRepos = RepoStub.repoList

    let expectation = expectation(description: "Each execute call should deliver independently")
    expectation.expectedFulfillmentCount = 2

    useCase.execute(page: 1, perPage: 20) { result in
      if case .success = result { expectation.fulfill() }
    }

    useCase.execute(page: 1, perPage: 20) { result in
      if case .success = result { expectation.fulfill() }
    }

    wait(for: [expectation], timeout: 2)
  }
}

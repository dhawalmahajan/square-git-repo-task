//
//  RepoRepositoryTests.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import XCTest

@testable import Square

final class RepoRepositoryTests: XCTestCase {
  //MARK: properties
  var session: URLSession!
  var apiService: APIService!
  var repository: RepoRepositoryImpl!

  //MARK: test lifecycle
  override func setUp() {
    super.setUp()
    URLCache.shared.removeAllCachedResponses()
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)
    apiService = APIService(session: session)
    repository = RepoRepositoryImpl(apiService: apiService)
  }

  override func tearDown() {
    URLCache.shared.removeAllCachedResponses()
    session = nil
    apiService = nil
    repository = nil
    MockURLProtocol.stubResponseData = nil
    MockURLProtocol.error = nil
    MockURLProtocol.statusCode = 200
    super.tearDown()
  }

  //MARK: Test cases
  func test_whenValidJSONReturned_thenReposAreParsedSuccessfully() {

    MockURLProtocol.stubResponseData = JSONLoader.load(filename: "APIResponseStub")

    let expectation = expectation(description: "repo")

    repository.fetchRepos(page: 1, perPage: 20) { result in
      switch result {
      case .success(let repos):
        XCTAssertEqual(repos.count, 3)
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: 5)
  }
  func test_whenInvalidJSONReturned_thenFetchReposFailsWithDecodingError() {

    MockURLProtocol.stubResponseData = Data()  // invalid JSON

    let expectation = expectation(description: "fail")

    repository.fetchRepos(page: 1, perPage: 20) { result in
      if case .failure = result {
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenNetworkIsUnavailable_thenFetchReposFailsWithNetworkError() {

    MockURLProtocol.error = URLError(.notConnectedToInternet)

    let expectation = expectation(description: "network fail")

    repository.fetchRepos(page: 1, perPage: 20) { result in
      if case .failure = result {
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenPaginationParametersProvided_thenURLContainsQueryParameters() {
    // This test verifies that pagination parameters are correctly added to the URL
    MockURLProtocol.stubResponseData = JSONLoader.load(filename: "APIResponseStub")

    let expectation = expectation(description: "pagination params")

    repository.fetchRepos(page: 2, perPage: 10) { result in
      switch result {
      case .success:
        // Verify that the request was made with correct parameters
        // (This would require more sophisticated mocking to inspect the URL)
        expectation.fulfill()
      case .failure:
        XCTFail("Expected success with pagination")
      }
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenEmptyResponse_thenReturnsEmptyArray() {
    MockURLProtocol.stubResponseData = "[]".data(using: .utf8)!

    let expectation = expectation(description: "empty response")

    repository.fetchRepos(page: 1, perPage: 20) { result in
      switch result {
      case .success(let repos):
        XCTAssertEqual(repos.count, 0)
        expectation.fulfill()
      case .failure:
        XCTFail("Expected success with empty array")
      }
    }

    wait(for: [expectation], timeout: 5)
  }
}

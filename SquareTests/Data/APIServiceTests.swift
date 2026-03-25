//
//  APIServiceTests.swift
//  SquareTests
//
//  Created by Dhawal Mahajan on 25/03/26.
//

import XCTest

@testable import Square

final class APIServiceTests: XCTestCase {

  var apiService: APIService!
  var session: URLSession!

  override func setUp() {
    super.setUp()
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)
    apiService = APIService(session: session)
  }

  override func tearDown() {
    apiService = nil
    session = nil
    MockURLProtocol.stubResponseData = nil
    MockURLProtocol.error = nil
    MockURLProtocol.statusCode = 200
    super.tearDown()
  }

  func test_whenValidResponse_thenReturnsData() {
    // Given
    let expectedData = "test data".data(using: .utf8)!
    MockURLProtocol.stubResponseData = expectedData

    let expectation = expectation(description: "API call completes")
    let url = URL(string: "https://api.example.com/test")!

    // When
    apiService.request(url: url) { result in
      // Then
      switch result {
      case .success(let data):
        XCTAssertEqual(data, expectedData)
        expectation.fulfill()
      case .failure:
        XCTFail("Expected success, got failure")
      }
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenNetworkError_thenReturnsError() {
    // Given
    MockURLProtocol.error = URLError(.notConnectedToInternet)

    let expectation = expectation(description: "API call fails")
    let url = URL(string: "https://api.example.com/test")!

    // When
    apiService.request(url: url) { result in
      // Then
      switch result {
      case .success:
        XCTFail("Expected failure, got success")
      case .failure(let error):
        XCTAssertTrue(error is URLError)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenCachedResponseAvailable_thenReturnsCachedData() {
    // Given
    let expectedData = "cached data".data(using: .utf8)!
    let url = URL(string: "https://api.example.com/cached")!

    // Pre-populate cache
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let cachedResponse = CachedURLResponse(response: response, data: expectedData)
    URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))

    let expectation = expectation(description: "API call returns cached data")

    // When
    apiService.request(url: url) { result in
      // Then
      switch result {
      case .success(let data):
        XCTAssertEqual(data, expectedData)
        expectation.fulfill()
      case .failure:
        XCTFail("Expected success with cached data, got failure")
      }
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenRequestMade_thenResponseIsCached() {
    // Given
    let expectedData = "response data".data(using: .utf8)!
    MockURLProtocol.stubResponseData = expectedData

    let url = URL(string: "https://api.example.com/cache-test")!
    let expectation = expectation(description: "API call completes and caches")

    // When
    apiService.request(url: url) { result in
      // Then
      switch result {
      case .success(let data):
        XCTAssertEqual(data, expectedData)

        // Check if response was cached
        let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url))
        XCTAssertNotNil(cachedResponse)
        XCTAssertEqual(cachedResponse?.data, expectedData)

        expectation.fulfill()
      case .failure:
        XCTFail("Expected success, got failure")
      }
    }

    wait(for: [expectation], timeout: 5)
  }
}

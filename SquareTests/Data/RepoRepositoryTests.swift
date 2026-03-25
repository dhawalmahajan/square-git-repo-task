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
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        apiService = APIService(session: session)
        repository = RepoRepositoryImpl(apiService: apiService)
    }

    override func tearDown() {
        session = nil
        apiService = nil
        repository = nil
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.error = nil
        MockURLProtocol.statusCode = 200
        super.tearDown()
    }

    func test_whenValidJSONReturned_thenReposAreParsedSuccessfully() {

        MockURLProtocol.stubResponseData = JSONLoader.load(filename: "APIResponseStub")


        let expectation = expectation(description: "repo")

        repository.fetchRepos { result in
            switch result {
            case .success(let repos):
                XCTAssertEqual(repos.count, 1)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
    func test_whenInvalidJSONReturned_thenFetchReposFailsWithDecodingError() {

        MockURLProtocol.stubResponseData = Data() // invalid JSON


        let expectation = expectation(description: "fail")

        repository.fetchRepos { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
    
    func test_whenNetworkIsUnavailable_thenFetchReposFailsWithNetworkError() {

        MockURLProtocol.error = URLError(.notConnectedToInternet)

        let expectation = expectation(description: "network fail")

        repository.fetchRepos { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
}

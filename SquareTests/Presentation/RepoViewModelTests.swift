//
//  RepoViewModelTests.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import XCTest
@testable import Square
final class RepoViewModelTests: XCTestCase {
    //MARK: properties
    private var mockRepo: MockRepoRepository! = nil
    private var useCase: FetchReposUseCase! = nil
    private var viewModel: RepoViewModel! = nil
    //MARK: test lifecycle
    override func setUp() {
        super.setUp()
        print("✅ Step 1: creating mockRepo")
            mockRepo = MockRepoRepository()
            
            print("✅ Step 2: setting mockRepos")
            mockRepo.mockRepos = RepoStub.repoList
            
            print("✅ Step 3: creating useCase")
            useCase = FetchReposUseCase(repository: mockRepo)
            
            print("✅ Step 4: creating viewModel")
            viewModel = RepoViewModel(useCase: useCase, scheduler: { $0() })
            
            print("✅ Step 5: setUp complete")
    }

    override func tearDown() {
        viewModel = nil
        useCase = nil
        mockRepo = nil
        super.tearDown()
    }
    
    //MARK: test cases
    func test_whenFetchSucceeds_thenViewModelEmitsSuccessStateWithRepos() {
        
        let expectation = XCTestExpectation(description: "Success")
        
        viewModel.onStateChange = { state in
            if case .success(let repos) = state {
                XCTAssertEqual(repos.count, 2)
                expectation.fulfill()
            }
        }
        
        viewModel.fetchRepos()
        
        wait(for: [expectation], timeout: 2)
    }
    func test_whenFetchFails_thenViewModelEmitsErrorState() {

        mockRepo.shouldFail = true

        let expectation = expectation(description: "failure")

        viewModel.onStateChange = { state in
            if case .error(_) = state {
                expectation.fulfill()
            }
        }

        viewModel.fetchRepos()

        wait(for: [expectation], timeout: 2)
    }
    func test_whenFetchStarts_thenViewModelEmitsLoadingStateFirst() {


        let expectation = expectation(description: "loading")

        viewModel.onStateChange = { state in
            if case .loading = state {
                expectation.fulfill()
            }
        }

        viewModel.fetchRepos()

        wait(for: [expectation], timeout: 1)
    }
    func test_whenRepositoryReturnsEmptyList_thenViewModelEmitsSuccessWithEmptyRepos() {


        mockRepo.mockRepos = []

        let expectation = expectation(description: "empty")

        viewModel.onStateChange = { state in
            if case .success(let repos) = state {
                XCTAssertTrue(repos.isEmpty)
                expectation.fulfill()
            }
        }

        viewModel.fetchRepos()

        wait(for: [expectation], timeout: 1)
    }
    func test_whenFetchSucceeds_thenViewModelEmitsLoadingFollowedBySuccess() {


        mockRepo.mockRepos = RepoStub.repoList


        var states: [RepoState] = []

        let expectation = expectation(description: "states")

        viewModel.onStateChange = { state in
            states.append(state)

            if case .success = state {
                XCTAssertEqual(states.count, 2) // loading + success
                expectation.fulfill()
            }
        }

        viewModel.fetchRepos()

        wait(for: [expectation], timeout: 1)
    }
}


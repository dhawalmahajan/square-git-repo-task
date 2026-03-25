//
//  MockRepoRepository.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import Foundation

@testable import Square

final class MockRepoRepository: RepoRepository {

  var shouldFail = false
  var mockRepos: [Repo] = []

  func fetchRepos(page: Int, perPage: Int, completion: @escaping (Result<[Repo], Error>) -> Void) {

    if shouldFail {
      completion(.failure(URLError(.badServerResponse)))
    } else {
      completion(.success(mockRepos))
    }
  }
}

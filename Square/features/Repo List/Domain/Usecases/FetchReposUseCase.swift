//
//  FetchReposUseCase.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

final class FetchReposUseCase {
  //MARK: properties
  private let repository: RepoRepository

  //MARK: Initializer
  init(repository: RepoRepository) {
    self.repository = repository
  }

  func execute(
    page: Int = 1, perPage: Int = 20, completion: @escaping (Result<[Repo], Error>) -> Void
  ) {
    repository.fetchRepos(page: page, perPage: perPage, completion: completion)
  }
}

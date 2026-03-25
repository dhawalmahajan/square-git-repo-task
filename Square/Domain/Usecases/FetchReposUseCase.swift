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

    func execute(completion: @escaping (Result<[Repo], Error>) -> Void) {
        repository.fetchRepos(completion: completion)
    }
}

//
//  RepoRepository.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

//MARK: Protocol
protocol RepoRepository {
    func fetchRepos(completion: @escaping (Result<[Repo], Error>) -> Void)
}

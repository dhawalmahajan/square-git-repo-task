//
//  RepoRepository.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

//MARK: Protocol
protocol RepoRepository {
  func fetchRepos(page: Int, perPage: Int, completion: @escaping (Result<[Repo], Error>) -> Void)
}

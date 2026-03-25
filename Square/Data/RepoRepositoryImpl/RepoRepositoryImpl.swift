//
//  RepoRepositoryImpl.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

import Foundation
final class RepoRepositoryImpl: RepoRepository {
    //MARK: properties
    static let apiUrl = "https://api.github.com/orgs/square/repos"

    private let apiService: APIService

    //MARK: Initializer
    init(apiService: APIService) {
        self.apiService = apiService
    }

    func fetchRepos(completion: @escaping (Result<[Repo], Error>) -> Void) {

        guard let url = URL(string: RepoRepositoryImpl.apiUrl) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        apiService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let dto = try JSONDecoder().decode([RepoDTO].self, from: data)
                    let repos = dto.map { $0.toDomain() }
                    completion(.success(repos))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

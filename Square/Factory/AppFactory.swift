//
//  AppFactory.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

import UIKit

//MARK: Factory
struct AppFactory {

    static func makeRepoList() -> UIViewController {
        let api = APIService()
        let repo = RepoRepositoryImpl(apiService: api)
        let useCase = FetchReposUseCase(repository: repo)
        let vm = RepoViewModel(useCase: useCase)

        return UINavigationController(rootViewController: RepoListViewController(viewModel: vm))
       
    }
}

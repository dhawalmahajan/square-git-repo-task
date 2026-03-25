//
//  RepoViewModel.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import Foundation
enum RepoState {
    case idle
    case loading
    case success([Repo])
    case error(String)
}

final class RepoViewModel {
    //MARK: properties
    private let useCase: FetchReposUseCase
    private let scheduler: (@escaping () -> Void) -> Void
    var onStateChange: ((RepoState) -> Void)?
    
    //MARK: initializer
    init(useCase: FetchReposUseCase,scheduler: @escaping (@escaping () -> Void) -> Void = { DispatchQueue.main.async(execute: $0) }) {
        self.useCase = useCase
        self.scheduler = scheduler
    }

    func fetchRepos() {
        onStateChange?(.loading)

        useCase.execute { [weak self] result in
            self?.scheduler {
                switch result {
                case .success(let repos):
                    self?.onStateChange?(.success(repos))

                case .failure(let error):
                    self?.onStateChange?(.error(error.localizedDescription))
                }
            }
        }
    }
}

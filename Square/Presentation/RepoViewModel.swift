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
  case success([Repo], isFirstPage: Bool)
  case error(String)
}

final class RepoViewModel {
  //MARK: properties
  private let useCase: FetchReposUseCase
  private let scheduler: (@escaping () -> Void) -> Void
  var onStateChange: ((RepoState) -> Void)?
  private var currentPage = 1
  private let perPage = 20
  private var isLoading = false

  //MARK: initializer
  init(
    useCase: FetchReposUseCase,
    scheduler: @escaping (@escaping () -> Void) -> Void = { DispatchQueue.main.async(execute: $0) }
  ) {
    self.useCase = useCase
    self.scheduler = scheduler
  }

  func fetchRepos(isLoadMore: Bool = false) {
    if isLoading { return }
    isLoading = true

    if !isLoadMore {
      currentPage = 1
      onStateChange?(.loading)
    }

    useCase.execute(page: currentPage, perPage: perPage) { [weak self] result in
      guard let self = self else { return }
      self.scheduler {
        self.isLoading = false
        switch result {
        case .success(let repos):
          if isLoadMore {
            // For load more, we would need to append, but since we don't have existing repos here,
            // we'll handle this in the view controller
            self.onStateChange?(.success(repos, isFirstPage: false))
          } else {
            self.onStateChange?(.success(repos, isFirstPage: true))
          }
          self.currentPage += 1

        case .failure(let error):
          self.onStateChange?(.error(error.localizedDescription))
        }
      }
    }
  }

  func loadMoreRepos() {
    fetchRepos(isLoadMore: true)
  }
}

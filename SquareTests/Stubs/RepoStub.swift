//
//  RepoStub.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
@testable import Square

struct RepoStub {

  static let repo1 = Repo(
    id: 1, name: "Repo1", description: "Description for Repo1",
    avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4")

  static let repo2 = Repo(
    id: 2, name: "Repo2", description: "Description for Repo2",
    avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4")

  static let repo3 = Repo(
    id: 3, name: "Repo3", description: "Description for Repo3",
    avatarUrl: "https://avatars.githubusercontent.com/u/3?v=4")

  static let repoList = [
    Repo(
      id: 1, name: "Repo1", description: "Description for Repo1",
      avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4"),
    Repo(
      id: 2, name: "Repo2", description: "Description for Repo2",
      avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4"),
    Repo(
      id: 3, name: "Repo3", description: "Description for Repo3",
      avatarUrl: "https://avatars.githubusercontent.com/u/3?v=4"),
  ]
}

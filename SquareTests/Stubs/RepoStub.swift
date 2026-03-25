//
//  RepoStub.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
@testable import Square
struct RepoStub {

    static let repo1 = Repo(id: 1, name: "Repo1", description: "Desc1")

    static let repoList = [
        Repo(id: 1, name: "Repo1", description: "Desc1"),
        Repo(id: 2, name: "Repo2", description: "Desc2")
    ]
}

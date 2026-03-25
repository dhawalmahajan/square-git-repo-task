//
//  RepoDTO.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

struct RepoDTO: Codable {
    let id: Int
    let name: String
    let description: String?
}
//MARK: Extension
extension RepoDTO {
    func toDomain() -> Repo {
        Repo(id: id, name: name, description: description)
    }
}

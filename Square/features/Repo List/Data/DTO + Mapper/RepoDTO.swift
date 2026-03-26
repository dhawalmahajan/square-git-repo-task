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
    let owner: Owner
}
struct Owner: Codable {
    let avatarURL: String
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
    }
}
//MARK: Extension
extension RepoDTO {
    func toDomain() -> Repo {
        Repo(id: id, name: name, description: description, avatarUrl: owner.avatarURL)
    }
}

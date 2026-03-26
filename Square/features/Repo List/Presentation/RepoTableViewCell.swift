//
//  RepoTableViewCell.swift
//  Square
//
//  Created by Dhawal Mahajan on 25/03/26.
//

import UIKit

final class RepoTableViewCell: UITableViewCell {

  static let reuseIdentifier = "RepoTableViewCell"

  private let repoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 25
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .gray
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    contentView.addSubview(repoImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(descriptionLabel)

    NSLayoutConstraint.activate([
      repoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      repoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      repoImageView.widthAnchor.constraint(equalToConstant: 50),
      repoImageView.heightAnchor.constraint(equalToConstant: 50),

      nameLabel.leadingAnchor.constraint(equalTo: repoImageView.trailingAnchor, constant: 12),
      nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      descriptionLabel.leadingAnchor.constraint(
        equalTo: repoImageView.trailingAnchor, constant: 12),
      descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
      descriptionLabel.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor, constant: -16),
      descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
    ])
  }

  func configure(with repo: Repo) {
    nameLabel.text = repo.name
    descriptionLabel.text = repo.description ?? "No description"

    if let avatarUrl = repo.avatarUrl, let url = URL(string: avatarUrl) {
      repoImageView.image = nil  // Clear previous image
      ImageCacheManager.shared.loadImage(from: url) { [weak self] image in
        self?.repoImageView.image = image ?? UIImage(systemName: "folder")
      }
    } else {
      repoImageView.image = UIImage(systemName: "folder")
    }
  }
}

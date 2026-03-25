import UIKit

final class RepoListViewController: UIViewController {

  //MARK: properties
  private let tableView = UITableView()
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let refreshControl = UIRefreshControl()

  private let viewModel: RepoViewModel
  private var repos: [Repo] = []
  private var isLoadingMore = false

  //MARK: initializer
  init(viewModel: RepoViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //MARK: View lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Square Repos"
    view.backgroundColor = .white

    setupUI()
    bindViewModel()

    viewModel.fetchRepos()
  }

  private func setupUI() {
    tableView.frame = view.bounds
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(
      RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.reuseIdentifier)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 80

    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    tableView.refreshControl = refreshControl

    view.addSubview(tableView)

    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
  }

  @objc private func refreshData() {
    viewModel.fetchRepos()
  }

  private func bindViewModel() {
    viewModel.onStateChange = { [weak self] state in
      self?.render(state)
    }
  }

  private func render(_ state: RepoState) {
    switch state {
    case .idle:
      break

    case .loading:
      if !refreshControl.isRefreshing {
        activityIndicator.startAnimating()
      }

    case .success(let repos, let isFirstPage):
      activityIndicator.stopAnimating()
      refreshControl.endRefreshing()

      if isFirstPage {
        self.repos = repos
      } else {
        self.repos.append(contentsOf: repos)
      }
      isLoadingMore = false
      tableView.reloadData()

    case .error(let message):
      activityIndicator.stopAnimating()
      refreshControl.endRefreshing()
      isLoadingMore = false
      showError(message)
    }
  }

  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

    alert.addAction(
      UIAlertAction(title: "Retry", style: .default) { _ in
        self.viewModel.fetchRepos()
      })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
  }

  private func loadMoreData() {
    if !isLoadingMore {
      isLoadingMore = true
      viewModel.loadMoreRepos()
    }
  }
}

//MARK: UITableViewDatasource
extension RepoListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    repos.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    guard
      let cell = tableView.dequeueReusableCell(
        withIdentifier: RepoTableViewCell.reuseIdentifier, for: indexPath) as? RepoTableViewCell
    else {
      return UITableViewCell()
    }

    let repo = repos[indexPath.row]
    cell.configure(with: repo)
    return cell
  }
}

//MARK: UITableViewDelegate
extension RepoListViewController: UITableViewDelegate {

  func tableView(
    _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
  ) {
    // Load more when reaching the last 5 items
    if indexPath.row == repos.count - 5 {
      loadMoreData()
    }
  }
}

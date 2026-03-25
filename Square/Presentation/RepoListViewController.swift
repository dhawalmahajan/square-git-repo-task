import UIKit

final class RepoListViewController: UIViewController {

    //MARK: properties
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel: RepoViewModel
    private var repos: [Repo] = []

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
        view.addSubview(tableView)

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
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
            activityIndicator.startAnimating()

        case .success(let repos):
            activityIndicator.stopAnimating()
            self.repos = repos
            tableView.reloadData()

        case .error(let message):
            activityIndicator.stopAnimating()
            showError(message)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.viewModel.fetchRepos()
        })

        present(alert, animated: true)
    }
}

extension RepoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let repo = repos[indexPath.row]

        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.description ?? "No description"
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}

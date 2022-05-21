import UIKit
import Combine

protocol DetailViewControllerDelegate: AnyObject {
    func didFinish(_ viewController: UIViewController)
    func didRequestImage(_ viewController: UIViewController, size: CGSize)
}

class PhlogDetailViewController: UITableViewController {

    @IBOutlet weak var textView: UITextView!

    var viewModel: DetailViewModel!
    weak var delegate: DetailViewControllerDelegate?

    private var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        textView.delegate = self
        setUpNavigationBar()
        addMenu()
        subscribeTo(viewModel: viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    // MARK: - View Model
    private func subscribeTo(viewModel: DetailViewModel) {
        title = viewModel.date
        textView.text = viewModel.body
        // Because setting text property programmatically doesn't trigger textViewDidChange
        // It's either calling this method manually or subclassing UITextView
        textView.textViewDidChange(NSNotification(name: UITextView.textDidChangeNotification,
                                                  object: textView))
        textView.textPublisher
            .assign(to: &viewModel.$body)

        viewModel.$image
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                // By default .contentInsetAdjustmentBehavior is .automatic
                // I keep it that way because if there is no image, then the top cell will overlap navigation bar
                // Disable it otherwise
                self.tableView.contentInsetAdjustmentBehavior = .never
                self.tableView.reloadData()
            }
            .store(in: &cancellable)

        viewModel.$address
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellable)

        viewModel.$isMenuActive
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &cancellable)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            .store(in: &cancellable)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.numberOfRows(section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard Section(rawValue: section) == .image else {  return UITableView.automaticDimension  }
        guard viewModel.image != nil else { return UITableView.automaticDimension }
        return viewModel.headerViewHeight
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard Section(rawValue: section) == .text else { return nil }
        return viewModel.address
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard Section(rawValue: section) == .image else { return nil }

        let imageView = UIImageView(image: viewModel.image)
        imageView.contentMode = .scaleAspectFill

        return imageView
    }

    // MARK: - Actions
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        delegate?.didRequestImage(self, size: .zero)
    }


    @IBAction func addLocationTapped(_ sender: UIButton) {
        viewModel.addLocation()
    }


    @objc func saveTapped() {
        viewModel.save()
        delegate?.didFinish(self)
    }

    public func removeTapped() {
        viewModel.remove()
        delegate?.didFinish(self)
    }

    // MARK: UI
    private func setUpNavigationBar() {
        // We don't want large title for this particular view controller since
        // it display the date in title
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.tableView.contentInsetAdjustmentBehavior = .automatic
    }

    private func addMenu() {
        let menuImage = UIImage(systemName: "circle.grid.2x1.fill")

        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: "Save",
                     image: UIImage(systemName: "tray.and.arrow.down.fill"),
                     handler: { [weak self] _ in self?.saveTapped() } ),

            UIAction(title: "Delete",
                     image: UIImage(systemName: "trash.fill"),
                     attributes: .destructive,
                     handler: { [weak self] _ in self?.removeTapped() } ),
        ])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "",
                                                                 image: menuImage,
                                                                 primaryAction: nil,
                                                                 menu: barButtonMenu)
    }
}

// --------------------------------------
// MARK: - Extensions
// --------------------------------------
extension PhlogDetailViewController {
    private enum Section: Int, CaseIterable {
        case image
        case text

        static var numberOfSections: Int {
            return self.allCases.count
        }

        static func numberOfRows(_ section: Int) -> Int {
            switch Section(rawValue: section) {
            case .image:
                return 1
            case .text:
                return 1
            default:
                return 0
            }
        }
    }
}

// MARK: - UITextView Delegate
extension PhlogDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
    }
}

// MARK: - Storyboarded Protocol
extension PhlogDetailViewController: Storyboarded {
    static var name: String {
        return "PhlogDetailViewController"
    }
}

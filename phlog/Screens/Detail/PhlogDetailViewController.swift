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
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.numberOfRows(section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard Section.byIndex(section) == .image else {  return UITableView.automaticDimension  }
        guard viewModel.image != nil else { return UITableView.automaticDimension }
        return viewModel.headerViewHeight
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard Section.byIndex(section) == .text else { return nil }
        return viewModel.address
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard Section.byIndex(section) == .image else { return nil }

        let imageView = UIImageView(image: viewModel.image)
        imageView.contentMode = .scaleAspectFill
        roundViewCorners(imageView)
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
        self.tableView.contentInsetAdjustmentBehavior = .never
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

    private func roundViewCorners(_ view: UIView) {
        let corners: UIRectCorner = [.bottomLeft, .bottomRight]
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
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

        static func byIndex(_ index: Int) -> Section {
            guard index < self.allCases.count else { fatalError("Sections counts do not match") }
            return self.allCases[index]
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

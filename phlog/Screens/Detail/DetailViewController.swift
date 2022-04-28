//
//  DetailViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 10.01.2022.
//

import UIKit
import Combine

protocol DetailViewControllerDelegate: AnyObject {
    func didFinish(_ viewController: UIViewController)
    func didRequestImage(_ viewController: UIViewController, size: CGSize)
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var viewModel: DetailViewModel!
    weak var delegate: DetailViewControllerDelegate?
    
    private var cancellable = Set<AnyCancellable>()
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        
        // We don't want large title for this particular view controler since
        // it display the date in title
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addMenu()
        subscribeTo(viewModel: viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundImageCorners()
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
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
            .store(in: &cancellable)
        
        viewModel.$isMenuActive
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &cancellable)
    }
    
    
    // MARK: - Actions
    @objc func saveTapped() {
        viewModel?.save()
        delegate?.didFinish(self)
    }
    
    public func removeTapped() {
        viewModel?.remove()
        delegate?.didFinish(self)
    }
    
    @IBAction func imageViewTapped(_ sender: UITapGestureRecognizer) {

        delegate?.didRequestImage(self, size: imageView.bounds.size)
    }
    
    // MARK: - UI
    private func roundImageCorners() {
        let corners: UIRectCorner = [.bottomLeft, .bottomRight]
        let path = UIBezierPath(roundedRect: imageView.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        imageView.layer.mask = maskLayer
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


extension DetailViewController: Storyboarded {
    static var name: String {
        return "DetailViewController"
    }
}

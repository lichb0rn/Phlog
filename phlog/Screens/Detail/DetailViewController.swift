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
        guard viewModel.verifyLibraryPermissions() else {
            showAlert()
            return
        }
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
}


extension DetailViewController {
    private func showAlert() {
        let alertViewController = UIAlertController(
            title: "Access denied",
            message: "The app need PhotoLibrary permissions to show your Library",
            preferredStyle: .alert)
        
        alertViewController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        self.present(alertViewController, animated: true)
    }
}


extension DetailViewController: Storyboarded {
    static var name: String {
        return "DetailViewController"
    }
}

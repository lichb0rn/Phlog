//
//  DetailViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 10.01.2022.
//

import UIKit
import Combine

public protocol DetailViewControllerDelegate: AnyObject {
    func didFinish(_ viewController: UIViewController)
    func didRequestImage(_ viewController: UIViewController)
}

public class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    public var viewModel: DetailViewModel!
    public weak var delegate: DetailViewControllerDelegate?
    
    private var cancellable = Set<AnyCancellable>()
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        
        // We don't want large title for this particular view controler since
        // it display the date in title
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        configureView(with: viewModel)
    }
    

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundImageCorners()
    }
    
    private func configureView(with viewModel: DetailViewModel) {
        title = viewModel.date
        textView.text = viewModel.body
        // Because setting text property programmatically doesn't trigger textViewDidChange
        // It's either calling this method manually or subclassing UITextView
        textView.textViewDidChange(NSNotification(name: UITextView.textDidChangeNotification,
                                                  object: textView))
        textView.textPublisher
            .assign(to: &viewModel.$body)
        
        viewModel.$image
            .sink { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.imageView.contentMode = .scaleAspectFill
                }
            }
            .store(in: &cancellable)
        viewModel.fetchImage(targetSize: imageView.frame.size)
    }
    
    private func roundImageCorners() {
        let corners: UIRectCorner = [.bottomLeft, .bottomRight]
        let path = UIBezierPath(roundedRect: imageView.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        imageView.layer.mask = maskLayer
    }

    
    @objc public func saveTapped() {
        viewModel?.save()
        delegate?.didFinish(self)
    }
    
    public func removeTapped() {
        viewModel?.remove()
        delegate?.didFinish(self)
    }
    
    @IBAction func imageViewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.didRequestImage(self)
    }
}



extension DetailViewController: Storyboarded {
    static var name: String {
        return "DetailViewController"
    }
}

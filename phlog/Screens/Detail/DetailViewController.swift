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
    
    private var cancellable = Set<AnyCancellable>()
    public var viewModel: PhlogDetailViewModel?
    public weak var delegate: DetailViewControllerDelegate?
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // We don't want the tab bar on this screen
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We don't want large title for this particular view controler since
        // it display the date in title
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
        
        if let viewModel = viewModel {
            configureView(with: viewModel)
        }
    }
    
    private func configureView(with viewModel: PhlogDetailViewModel) {
        title = viewModel.date
        textView.text = viewModel.body
        // Because setting text property programmatically doesn't trigger textViewDidChange
        // It's either calling this method manually or subclassing UITextView
        textView.textViewDidChange(NSNotification(name: UITextView.textDidChangeNotification,
                                                  object: textView))
    
        textView.textPublisher
            .assign(to: &viewModel.$body)
        
        viewModel.imageViewSize = imageView.frame.size
        viewModel.fetchImage()
        viewModel.$image
            .sink(receiveValue: { [weak self] image in
                if let image = image {
                    self?.imageView.image = image
                    self?.imageView.contentMode = .scaleAspectFill
                } else {
            
                    // TODO: Make and image with description "tap to add image"
                    self?.imageView.image = UIImage(systemName: "camera")
                    self?.imageView.contentMode = .scaleAspectFit
                }
            })
            .store(in: &cancellable)
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

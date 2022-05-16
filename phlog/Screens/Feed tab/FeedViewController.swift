//
//  ViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import UIKit


protocol FeedViewControllerDelegate: AnyObject {
    func didSelectPhlog(_ viewController: FeedViewController, phlog: PhlogPost)
}

final class FeedViewController: UIViewController {
    
    // --------------------------------------
    // MARK: - Properties
    // --------------------------------------
    weak var delegate: FeedViewControllerDelegate?
    var phlogProvider: PhlogService!
    var viewModel: FeedViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetch()
    }
    
    private func configureViewController() {
        FeedCell.registerCellXib(with: collectionView)
        collectionView.delegate = self
        
        viewModel = FeedViewModel(collectionView: collectionView, phlogProvider: phlogProvider)
    }
    
}

// --------------------------------------
// MARK: - CollectionView Delegate
// --------------------------------------
extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let phlog = viewModel.phlog(for: indexPath)
        delegate?.didSelectPhlog(self, phlog: phlog)
    }
}


// --------------------------------------
// MARK: - Storyboarded protocol conformance
// --------------------------------------
extension FeedViewController: Storyboarded {
    static var name: String {
        return "FeedViewController"
    }
}


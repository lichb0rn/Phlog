//
//  ViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import UIKit


public protocol FeedViewControllerDelegate: AnyObject {
    func didSelectPhlog(_ viewController: FeedViewContoller, phlog: PhlogPost)
}

public final class FeedViewContoller: UIViewController {
    
    // --------------------------------------
    // MARK: - Properties
    // --------------------------------------
    public weak var delegate: FeedViewControllerDelegate?
    public var phlogProvider: PhlogService!
    public var viewModel: FeedViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
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
extension FeedViewContoller: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let phlog = viewModel.phlog(for: indexPath)
        delegate?.didSelectPhlog(self, phlog: phlog)
    }
}


// --------------------------------------
// MARK: - Storyboarded protocol conformance
// --------------------------------------
extension FeedViewContoller: Storyboarded {
    static var name: String {
        return "FeedViewContoller"
    }
}


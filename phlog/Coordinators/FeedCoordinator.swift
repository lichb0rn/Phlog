//
//  FeedCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import Foundation
import UIKit

public class FeedCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    private let phlogManager: PhlogManager
    
    private lazy var feedViewController = FeedViewContoller.instantiate(from: .feed)

    
    public init(router: Router, phlogManager: PhlogManager) {
        self.router = router
        self.phlogManager = phlogManager
    }
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        feedViewController.delegate = self
        feedViewController.phlogManager = phlogManager
        router.present(feedViewController, animated: animated, completion: completion)
    }    
}

extension FeedCoordinator: FeedViewControllerDelegate {
    public func didSelectPhlog(_ viewController: FeedViewContoller, phlog: PhlogPost) {
        let modalNavigationRouter = ModalNavigationRouter(parentViewController: toPresentable())
        let phlogViewModel = PhlogDetailViewModel(phlog: phlog, phlogManager: phlogManager)
        let coordinator = DetailCoordinator(router: modalNavigationRouter, viewModel: phlogViewModel)
        self.startChild(coordinator, animated: true, completion: nil)
    }
}
//
//  FeedCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import Foundation
import UIKit

class FeedCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    private let phlogProvider: PhlogService
    
    private lazy var feedViewController = FeedViewController.instantiate(from: .feed)

    
    init(router: Router, phlogProvider: PhlogService) {
        self.router = router
        self.phlogProvider = phlogProvider
    }
    
    func start(animated: Bool, completion: (() -> Void)?) {
        feedViewController.delegate = self
        feedViewController.phlogProvider = phlogProvider
        router.present(feedViewController, animated: animated, completion: completion)
    }    
}

extension FeedCoordinator: FeedViewControllerDelegate {
    func didSelectPhlog(_ viewController: FeedViewController, phlog: PhlogPost) {
        let modalNavigationRouter = ModalNavigationRouter(parentViewController: toPresentable())
        let coordinator = DetailCoordinator(router: modalNavigationRouter, phlogProvider: phlogProvider, phlog: phlog)
        self.startChild(coordinator, animated: true, completion: nil)
    }
}

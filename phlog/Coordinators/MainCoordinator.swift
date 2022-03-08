//
//  AppFactory.swift
//  phlog
//
//  Created by Miroslav Taleiko on 18.12.2021.
//

import Foundation
import UIKit

public class MainCoordinator: NSObject, Coordinator {
    
    private let phlogManager = PhlogManager(db: CoreDataStack.shared)
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    
    private var tabBarController = TabController.instantiate(from: .main)
    private lazy var feedCoordinator = makeFeedCoordinator()
    private lazy var settingsCoordinator = makeSettingsCoordinator()
    private var tabs: [UIViewController: Coordinator] = [:]
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    public init(router: Router) {
        self.router = router
        super.init()
    }
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        router.present(tabBarController, animated: animated, completion: completion)
        setupTabs([feedCoordinator, settingsCoordinator])
        
        tabBarController.coordinator = self
        
        guard let index = tabBarController.viewControllers?.firstIndex(of: feedCoordinator.toPresentable()) else {
            return
        }
        tabBarController.selectedIndex = index
    }
    
    
    private func setupTabs(_ coordinators: [Coordinator]) {
        let viewControllers = coordinators.map { coordinator -> UIViewController in
            let viewController = coordinator.toPresentable()
            tabs[viewController] = coordinator
            coordinator.start(animated: false, completion: nil)
            return viewController
        }
        tabBarController.setViewControllers(viewControllers, animated: false)
    }
    
    public func toPresentable() -> UIViewController {
        return tabBarController
    }
}

// --------------------------------------
// MARK: - Tab Factories
// --------------------------------------
extension MainCoordinator {
    
    private func makeFeedCoordinator() -> FeedCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "photo.on.rectangle.fill"), tag: 0)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = FeedCoordinator(router: router, phlogManager: phlogManager)
        return coordinator
    }
    
    private func makeSettingsCoordinator() -> SettingsCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = SettingsCoordinator(router: router, phlogManager: phlogManager)
        return coordinator
    }
}

// --------------------------------------
// MARK: - Action button controll
// --------------------------------------
extension MainCoordinator: TabViewActionControll {
    
    public func tabViewActionButtonTapped(_ viewController: UIViewController) {
        let modalRouter = ModalNavigationRouter(parentViewController: viewController)
//        let actionCoordinator = ActionCoordinator(router: modalRouter, phlogManager: phlogManager)
        let coordinator = DetailCoordinator(router: modalRouter, phlogManager: phlogManager)
        self.startChild(coordinator, animated: true, completion: nil)
    }
}

//
//  AppFactory.swift
//  phlog
//
//  Created by Miroslav Taleiko on 18.12.2021.
//

import Foundation
import UIKit
import Photos

public class MainCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    
    private var tabBarController = TabController.instantiate(from: .main)
    private lazy var feedCoordinator = makeFeedCoordinator()
    private lazy var mapCoordinator = makeJournalDetailCoordinator()
    private var tabs: [UIViewController: Coordinator] = [:]
    
    private let phlogProvider: PhlogService
    
    // --------------------------------------
    // MARK: - Lifecycle
    // --------------------------------------
    public init(router: Router) {
        self.router = router
        
        let coreDataStack = CoreDataStack()
        self.phlogProvider = PhlogProvider(db: coreDataStack)
        
        super.init()
    }
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        router.present(tabBarController, animated: animated, completion: completion)
        setupTabs([feedCoordinator, mapCoordinator])
        
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
        let coordinator = FeedCoordinator(router: router, phlogProvider: phlogProvider)
        return coordinator
    }
    
    private func makeJournalDetailCoordinator() -> MapViewCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map.fill"), tag: 1)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = MapViewCoordinator(router: router, phlogProvider: phlogProvider)
        return coordinator
    }
}

// --------------------------------------
// MARK: - Action button control
// --------------------------------------
extension MainCoordinator: TabViewActionControll {
    
    public func tabViewActionButtonTapped(_ viewController: UIViewController) {
        guard verifyLibraryPermissions() else {
            tabBarController.showAlert(title: "Access denied",
                                       message: "The app need access to your Photo Library to add photos to phlogs.")
            return
        }
        
        let modalRouter = ModalNavigationRouter(parentViewController: viewController)
        let coordinator = DetailCoordinator(router: modalRouter, phlogProvider: phlogProvider)
        self.startChild(coordinator, animated: true, completion: nil)
    }
    
    private func verifyLibraryPermissions() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        var status: Bool = false
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { newStatus in
                status = newStatus == .authorized || newStatus == .limited
            } )
        case .restricted, .denied:
            status = false
        case .authorized, .limited:
            status = true
        @unknown default:
            status = false
        }
        return status
    }
    

}

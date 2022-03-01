//
//  NavigationRotuer.swift
//  phlog
//
//  Created by Miroslav Taleiko on 23.12.2021.
//

import UIKit

public class NavigationRouter: NSObject {
    
    public var rootViewController: UIViewController? {
        return navigationController.viewControllers.first
    }
    
    public let navigationController: UINavigationController
    private var onDismissCompletions: [UIViewController: () -> Void] = [:]
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
}

extension NavigationRouter: Router {
    
    public func setRootViewController(_ viewController: UIViewController, hideBar: Bool = false) {
        onDismissCompletions.forEach { $0.value() }
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.isNavigationBarHidden = hideBar
    }
    
    public func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        onDismissCompletions[viewController] = completion
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    public func dismiss(animated: Bool) {
        guard let rootViewController = rootViewController else {
            navigationController.popToRootViewController(animated: animated)
            return
        }
        performCompletion(rootViewController)
        navigationController.popToViewController(rootViewController, animated: animated)
    }
    
    private func performCompletion(_ viewController: UIViewController) {
        guard let completion = onDismissCompletions[viewController] else { return }
        completion()
        onDismissCompletions[viewController] = nil
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(poppedViewController) else {
            return
        }
        performCompletion(poppedViewController)
    }
}

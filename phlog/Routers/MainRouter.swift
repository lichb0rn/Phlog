//
//  AppRouter.swift
//  phlog
//
//  Created by Miroslav Taleiko on 20.12.2021.
//

import Foundation
import UIKit


class MainRouter {
    
    let window: UIWindow
    let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func presentBottomSheet(_ childViewController: UIViewController, completion: (() -> Void)? = nil) {
        let modalViewController = ModalViewController(child: childViewController)
        present(modalViewController, animated: false, completion: completion)
    }
}

extension MainRouter: Router {
    
    func setRootViewController(_ viewController: UIViewController, hideBar: Bool = false) {
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.isNavigationBarHidden = hideBar
    }
    func toPresentable() -> UIViewController { return navigationController }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    // We are not dismissing here, made only for conformance to Router protocol
    func dismiss(animated: Bool) {}

}

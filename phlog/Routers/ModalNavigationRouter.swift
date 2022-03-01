//
//  ModalNavigationRouter.swift
//  phlog
//
//  Created by Miroslav Taleiko on 26.12.2021.
//

import UIKit

public class ModalNavigationRouter: NSObject {
    
    public unowned let parentViewController: UIViewController
    
    public let navigationController: UINavigationController = UINavigationController()
    private var onDismissCompletions: [UIViewController: () -> Void] = [:]
    
    public init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        super.init()
        self.navigationController.delegate = self
    }
}

extension ModalNavigationRouter: Router {
    
    public func setRootViewController(_ viewController: UIViewController, hideBar: Bool = false) {
        
    }
    
    public func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        onDismissCompletions[viewController] = completion
        if navigationController.viewControllers.isEmpty {
            presentModally(viewController, animated: animated)
        } else {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    private func presentModally(_ viewController: UIViewController, animated: Bool) {
        addCancelButton(to: viewController)
        navigationController.setViewControllers([viewController], animated: false)
        parentViewController.present(navigationController, animated: animated, completion: nil)
    }
    
    private func addCancelButton(to viewController: UIViewController) {
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(cancelPressed))
    }
    
    @objc private func cancelPressed() {
        performOnDismissCompletion(navigationController.viewControllers.first!)
        dismiss(animated: true)
    }
    
    public func dismiss(animated: Bool) {
        if navigationController.viewControllers.count < 2 {
            performOnDismissCompletion(navigationController.viewControllers.first!)
            parentViewController.dismiss(animated: animated, completion: nil)
        } else {
            navigationController.popViewController(animated: animated)
        }
    }
    
    private func performOnDismissCompletion(_ viewController: UIViewController) {
        guard let completion = onDismissCompletions[viewController] else { return }
        completion()
        onDismissCompletions[viewController] = nil
    }
    
}


extension ModalNavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let viewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(viewController) else {
                  return
              }
        performOnDismissCompletion(viewController)
    }
}

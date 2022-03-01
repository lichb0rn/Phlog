//
//  ModalPresentRouter.swift
//  phlog
//
//  Created by Miroslav Taleiko on 31.12.2021.
//

import UIKit

public class ModalPresentRouter: NSObject {
    
    public unowned let parentViewController: UIViewController
    public let navigationController: UINavigationController
    
    private var onDismissCompletions: [UIViewController: () -> Void] = [:]
    
    public init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.navigationController = UINavigationController()
        super.init()
    }
}

extension ModalPresentRouter: Router {
    
    public func setRootViewController(_ viewController: UIViewController, hideBar: Bool = false) {
        
    }
    
    public func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        onDismissCompletions[viewController] = completion
        presentModally(viewController, animated: animated)
    }
    
    private func presentModally(_ viewController: UIViewController, animated: Bool) {
        parentViewController.present(viewController, animated: animated, completion: nil)
    }
    
    public func dismiss(animated: Bool) {
        performOnDismissCompletion(parentViewController.presentedViewController!)
        parentViewController.dismiss(animated: true, completion: nil)
    }
    
    private func performOnDismissCompletion(_ viewController: UIViewController) {
        guard let completion = onDismissCompletions[viewController] else { return }
        completion()
        onDismissCompletions[viewController] = nil
    }
    
}

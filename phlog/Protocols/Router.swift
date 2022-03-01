//
//  Router.swift
//  phlog
//
//  Created by Miroslav Taleiko on 20.12.2021.
//

import Foundation
import UIKit

public protocol Router: AnyObject, Presentable {
    
    var navigationController: UINavigationController { get }
    func present(_ viewController: UIViewController, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool)
}

extension Router {
    
    // Convinience methods
    public func present(_ viewController: UIViewController, animated: Bool) {
        present(viewController, animated: animated, completion: nil)
    }
    
    public func toPresentable() -> UIViewController {
        return navigationController
    }
}

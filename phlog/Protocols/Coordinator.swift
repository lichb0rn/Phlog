//
//  Coordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import Foundation
import UIKit



public protocol Coordinator: AnyObject, Presentable {
    var childCoordinators: [Coordinator] { get set }
    var router: Router { get }
    func start(animated: Bool, completion: (() -> Void)?)
    func startChild(_ child: Coordinator, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool)
}

extension Coordinator {
    
    public func startChild(_ child: Coordinator, animated: Bool, completion: (() -> Void)? = nil) {
        childCoordinators.append(child)
        child.start(animated: animated) { [weak self, weak child] in
            guard let strongSelf = self, let strongChild = child else { return }
            strongSelf.removeChild(strongChild)
            completion?()
        }
    }
    
    private func removeChild(_ child: Coordinator) {
        guard let idx = childCoordinators.firstIndex(where: { $0 === child }) else { return }
        childCoordinators.remove(at: idx)
    }
    
    public func dismiss(animated: Bool) {
        router.dismiss(animated: animated)
    }

    public func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
}

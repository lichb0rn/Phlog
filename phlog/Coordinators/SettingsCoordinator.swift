//
//  SettingsCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import Foundation
import UIKit

public class SettingsCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    private var phlogManager: PhlogManager
    
    private lazy var settingsViewController = SettingsViewController.instantiate(from: .settings)
    
    public init(router: Router, phlogManager: PhlogManager) {
        self.router = router
        self.phlogManager = phlogManager
    }
    
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        settingsViewController.delegate = self
        router.present(settingsViewController, animated: animated, completion: completion)
    }
    
}


extension SettingsCoordinator: SettingsViewControllerDelegate {
    
    public func changedLayout(to layoutIndex: Int) {
        print(layoutIndex)
    }
    
    public func removeRequested() {
        phlogManager.removeAll()
    }
    
}

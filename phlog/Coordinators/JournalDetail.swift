//
//  SettingsCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import Foundation
import UIKit

public class JournalDetailCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    private var phlogManager: PhlogManager
    
    private lazy var journalDetailViewController = JournalDetailViewController.instantiate(from: .settings)
    
    public init(router: Router, phlogManager: PhlogManager) {
        self.router = router
        self.phlogManager = phlogManager
    }
    
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        journalDetailViewController.delegate = self
        router.present(journalDetailViewController, animated: animated, completion: completion)
    }
    
}


extension JournalDetailCoordinator: JournalDetailDelegate {
    
    public func changedLayout(to layoutIndex: Int) {
        print(layoutIndex)
    }
    
    public func removeRequested() {
        phlogManager.removeAll()
    }
    
}

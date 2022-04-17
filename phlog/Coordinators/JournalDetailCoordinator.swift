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
    private var phlogProvider: PhlogService
    
    private lazy var journalDetailViewController = JournalDetailViewController.instantiate(from: .journal)
    
    public init(router: Router, phlogProvider: PhlogService) {
        self.router = router
        self.phlogProvider = phlogProvider
    }
    
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        router.present(journalDetailViewController, animated: animated, completion: completion)
    }
    
}

//
//  PcikerCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 11.12.2021.
//

import Foundation
import UIKit

public class ActionCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public let router: Router
    
    private var viewModel: PhlogDetailViewModel?
    private let phlogManager: PhlogManager
    private let viewController = DetailViewController.instantiate(from: .detail)
    
    public init(router: Router, phlogManager: PhlogManager) {
        self.router = router
        self.phlogManager = phlogManager
    }
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        viewController.delegate = self
        addSaveButton()
        router.present(viewController, animated: true, completion: completion)
    }
    
    private func addSaveButton() {
        self.viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                                      style: .done,
                                                                                      target: viewController,
                                                                                      action: #selector(viewController.saveTapped))
    }

    public func toPresentable() -> UIViewController {
        return viewController
    }
}

extension ActionCoordinator: DetailViewControllerDelegate {
    
    public func didFinish(_ viewController: UIViewController) {
        dismiss(animated: true)
    }
    
    public func didRequestImage(_ viewController: UIViewController) {
        let imagePickerCoordinator = ImagePickerCoordinator(router: router)
        imagePickerCoordinator.delegate = self
        startChild(imagePickerCoordinator, animated: true, completion: nil)
    }

}

extension ActionCoordinator: ImagePickerCoordinatorDelegate {
    
    public func didChoosePhoto(_ asset: String) {
        let newPhlog = phlogManager.newPhlog(asset)
        viewModel = PhlogDetailViewModel(phlog: newPhlog, phlogManager: phlogManager)
        viewController.viewModel = viewModel
    }
}

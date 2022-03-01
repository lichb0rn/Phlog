//
//  DetailCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 10.01.2022.
//

import Foundation
import UIKit
import PhotosUI

public class DetailCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var router: Router
    private let viewModel: PhlogDetailViewModel
    private let viewController = DetailViewController.instantiate(from: .detail)
    
    
    public init(router: Router, viewModel: PhlogDetailViewModel) {
        self.router = router
        self.viewModel = viewModel
    }
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        viewController.viewModel = viewModel
        viewController.delegate = self
        addSaveButton()
        router.present(viewController, animated: animated, completion: completion)
        viewController.navigationController?.isNavigationBarHidden = false
    }
    
    private func addSaveButton() {
        let menuImage = UIImage(systemName: "circle.grid.2x1.fill")
        
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: "Save",
                     image: UIImage(systemName: "tray.and.arrow.down.fill"),
                     handler: { [weak self] _ in self?.viewController.saveTapped() } ),
            
            UIAction(title: "Delete",
                     image: UIImage(systemName: "trash.fill"),
                     attributes: .destructive,
                     handler: { [weak self] _ in self?.viewController.removeTapped() } ),
        ])
        self.viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "",
                                                                                image: menuImage,
                                                                                primaryAction: nil,
                                                                                menu: barButtonMenu)
        
    }
    
    public func toPresentable() -> UIViewController {
        return viewController
    }
}


extension DetailCoordinator: DetailViewControllerDelegate {
    
    public func didFinish(_ viewController: UIViewController) {
        dismiss(animated: true)
    }
    
    public func didRequestImage(_ viewController: UIViewController) {
        let imagePickerCoordinator = ImagePickerCoordinator(router: router)
        imagePickerCoordinator.delegate = self
        startChild(imagePickerCoordinator, animated: true, completion: nil)
    }
}

extension DetailCoordinator: ImagePickerCoordinatorDelegate {

    public func didChoosePhoto(_ asset: String) {
        viewModel.updatePhoto(with: asset)
    }

}
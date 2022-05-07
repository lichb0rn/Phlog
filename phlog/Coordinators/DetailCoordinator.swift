//
//  DetailCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 10.01.2022.
//

import Foundation
import UIKit
import PhotosUI

class DetailCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var router: Router
    private var viewModel: DetailViewModel?
    private let phlogProvider: PhlogService
    private let viewController = DetailViewController.instantiate(from: .detail)
    
    
    init(router: Router, phlogProvider: PhlogService, phlog: PhlogPost? = nil) {
        self.router = router
        self.phlogProvider = phlogProvider
        self.viewModel = DetailViewModel(phlogProvider: phlogProvider, phlog: phlog)
    }
    
    func start(animated: Bool, completion: (() -> Void)?) {
        viewController.viewModel = viewModel
        viewController.delegate = self

        router.present(viewController, animated: animated, completion: completion)
        viewController.navigationController?.isNavigationBarHidden = false
    }
    
    func toPresentable() -> UIViewController {
        return viewController
    }
}


extension DetailCoordinator: DetailViewControllerDelegate {
    
    func didFinish(_ viewController: UIViewController) {
        dismiss(animated: true)
    }
    
    func didRequestImage(_ viewController: UIViewController, size: CGSize) {
        let imagePickerCoordinator = ImagePickerCoordinator(router: router)
        startChild(imagePickerCoordinator, animated: true) {
            [weak self] in
            guard let self = self else { return }
            let asset = imagePickerCoordinator.chosenAsset
            self.viewModel?.updatePhoto(with: asset, size: size)
        }
    }
}

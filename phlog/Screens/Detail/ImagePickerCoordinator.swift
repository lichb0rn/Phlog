//
//  ImagePickerCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 29.01.2022.
//

import UIKit
import PhotosUI


public class ImagePickerCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public let router: Router
    private var picker: PHPickerViewController!
    
    public var chosenAsset: String = ""
    
    
    public init(router: Router) {
        self.router = router
    }
    
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        picker = makePickerViewController()
        picker.delegate = self
        router.present(picker, animated: animated, completion: completion)
        picker.navigationController?.isNavigationBarHidden = true
    }
    

    public func toPresentable() -> UIViewController {
        return picker
    }
   
    private func makePickerViewController() -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.images
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .default
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }
}

// --------------------------------------
// MARK: - PHPicker Delegate and Authorization
// --------------------------------------
extension ImagePickerCoordinator: PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.navigationController?.isNavigationBarHidden = false
        dismiss(animated: true)
        
        let assetIdentifiers = results.compactMap(\.assetIdentifier)
        if let asset = assetIdentifiers.first {
            chosenAsset = asset
        }
    }
}


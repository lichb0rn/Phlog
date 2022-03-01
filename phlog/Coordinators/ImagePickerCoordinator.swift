//
//  ImagePickerCoordinator.swift
//  phlog
//
//  Created by Miroslav Taleiko on 29.01.2022.
//

import UIKit
import PhotosUI

public protocol ImagePickerCoordinatorDelegate: AnyObject {
    func didChoosePhoto(_ asset: String)
}

public class ImagePickerCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public let router: Router
    public weak var delegate: ImagePickerCoordinatorDelegate?
    
    
    private var picker: PHPickerViewController!
    
    public init(router: Router) {
        self.router = router
    }
    
    
    public func start(animated: Bool, completion: (() -> Void)?) {
        
        checkAuthorizationStatus { hasPermission in
            guard !hasPermission else { return }
            self.dismiss(animated: true)
            self.showAcessDenied()
        }
        
        picker = makePickerViewController()
        picker.delegate = self
        router.present(picker, animated: animated, completion: completion)
        picker.navigationController?.isNavigationBarHidden = true
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
    
    public func toPresentable() -> UIViewController {
        return picker
    }
    
    private func showAcessDenied() {
        // TODO: Make an alert
        print("Denied")
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
        if !assetIdentifiers.isEmpty {
            delegate?.didChoosePhoto(assetIdentifiers.first!)
        }
    }
    
    public func checkAuthorizationStatus(completion: @escaping(Bool) -> Void) {
        
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completion(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            completion(status == .authorized ? true : false)
        }
    }
}


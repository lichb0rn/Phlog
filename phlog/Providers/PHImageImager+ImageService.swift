//
//  PHImageImager+ImageService.swift
//  phlog
//
//  Created by Miroslav Taleiko on 20.04.2022.
//

import UIKit
import Photos


struct ImageData {
    let identitifier: String
    var image: UIImage?
}

protocol ImageService: AnyObject {
    
    func requestImage(for asset: ImageData,
                      targetSize: CGSize,
                      completion: @escaping (ImageData?) -> Void)
}

// --------------------------------------
// MARK: - PHImageManager + ImageService
// --------------------------------------
extension PHImageManager: ImageService {
    
    func requestImage(for asset: ImageData, targetSize: CGSize, completion: @escaping (ImageData?) -> Void) {
        guard let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [asset.identitifier],
                                                options: nil).lastObject else {
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.version = .current
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            let imgData = ImageData(identitifier: asset.identitifier,
                                    image: image)
            completion(imgData)
        }
        
        Self.default().requestImage(for: phAsset,
                                    targetSize: targetSize,
                                    contentMode: .aspectFill,
                                    options: options,
                                    resultHandler: resultHandler)
    }
    
    
}

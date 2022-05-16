//
//  UIImageView+Extension.swift
//  phlog
//
//  Created by Miroslav Taleiko on 27.03.2022.
//

import UIKit
import Photos

fileprivate var options: PHImageRequestOptions = {
    let options = PHImageRequestOptions()
    options.deliveryMode = .opportunistic
    options.isNetworkAccessAllowed = true
    options.resizeMode = .exact
    options.version = .current
    return options
}()

extension UIImageView {
    
    func fetchImageAsset(_ asset: PHAsset?,
                         targetSize size: CGSize,
                         contentMode: PHImageContentMode = .aspectFill,
                         options: PHImageRequestOptions = options,
                         completion: ((Bool) -> Void)?) {
        
        guard let asset = asset else {
            completion?(false)
            return
        }
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            DispatchQueue.main.async {
                self.image = image
                completion?(true)
            }
        }
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: size,
                                              contentMode: contentMode,
                                              options: options,
                                              resultHandler: resultHandler)
    }
}

//
//  ImageManager.swift
//  phlog
//
//  Created by Miroslav Taleiko on 10.04.2022.
//

import UIKit
import Photos


public protocol ImageService: AnyObject {
    var permissionsDeclined: Bool { get }
    
    func requestImage(for asset: ImageData,
                      targetSize: CGSize,
                      completion: @escaping (ImageData?) -> Void)
}

public struct ImageData {
    let identitifier: String
    var image: UIImage?
}

public class ImageProvider: ImageService {
    private let imageProvider = PHImageManager.default()
    
    public init() {}
    
    
    public var permissionsDeclined: Bool {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .denied
    }
    
    public func requestImage(for asset: ImageData,
                      targetSize: CGSize,
                      completion: @escaping (ImageData?) -> Void) {
        
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
        
        imageProvider.requestImage(for: phAsset,
                                   targetSize: targetSize,
                                   contentMode: .aspectFill,
                                   options: options,
                                   resultHandler: resultHandler)
    }
}

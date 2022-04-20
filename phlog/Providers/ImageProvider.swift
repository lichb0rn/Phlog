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

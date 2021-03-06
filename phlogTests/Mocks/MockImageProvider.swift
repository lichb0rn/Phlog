//
//  MockImageProvider.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 16.04.2022.
//

import UIKit
@testable import phlog

class MockImageProvider: ImageService {
    
    var permissionsDeclined: Bool = false
    var images: [String: UIImage] = testingImages()
    
    
    func requestImage(for asset: ImageData, targetSize: CGSize, completion: @escaping (ImageData?) -> Void) {
        var imgData = ImageData(identifier: asset.identifier)
        imgData.image = images[imgData.identifier]?.resizeTo(size: targetSize)
        completion(imgData)
    }
}

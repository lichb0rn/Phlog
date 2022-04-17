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
    
    
    func requestImage(for asset: ImageData, targetSize: CGSize, completion: @escaping (ImageData?) -> Void) {
        var imgData = ImageData(identitifier: asset.identitifier)
        imgData.image = UIImage(systemName: testingSymbols[0])!.resizeTo(size: targetSize)
        completion(imgData)
    }
    
    
}

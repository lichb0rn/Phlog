//
//  UIImage+Extension.swift
//  phlog
//
//  Created by Miroslav Taleiko on 26.02.2022.
//

import UIKit

extension UIImage {
    public func resizeTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    public func thumbnail(for desiredSize: CGSize) -> UIImage? {
        let widthScale = desiredSize.width / self.size.width
        let heightScale = desiredSize.height / self.size.height
        
        let scaleFactor = min(widthScale, heightScale)
        let scaledSize = CGSize(width: self.size.width * scaleFactor,
                                height: self.size.height * scaleFactor)        
        return self.resizeTo(size: scaledSize)
    }
}


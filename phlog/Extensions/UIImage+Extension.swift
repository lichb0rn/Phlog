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
}


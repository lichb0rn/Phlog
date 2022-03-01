//
//  UINavigationController+Extension.swift
//  phlog
//
//  Created by Miroslav Taleiko on 16.01.2022.
//

import UIKit

extension UINavigationController {
    public func configureBarAppearance() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = .clear
        self.navigationBar.isTranslucent = true
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupGradient(height: CGFloat, topColor: CGColor, bottomColor: CGColor) ->  CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [topColor,bottomColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: height)
        return gradient
    }
}

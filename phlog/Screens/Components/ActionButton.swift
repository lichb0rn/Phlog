//
//  ActionButton.swift
//  phlog
//
//  Created by Miroslav Taleiko on 14.12.2021.
//

import UIKit

class ActionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = 12
        self.backgroundColor = .systemGray5
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.shadowColor = UIColor.green.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
        self.layer.shouldRasterize = true
        
        let image = UIImage(systemName: "plus")
        self.setImage(image, for: .normal)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension ActionButton {
    func rotateImage(by degrees: CGFloat = -.pi, withDuration duration: CGFloat = 0.3) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = degrees
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.duration = duration

        self.imageView?.layer.add(animation, forKey: "rotationAnimation")
    }
}

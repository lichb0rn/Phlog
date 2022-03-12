//
//  ActionButton.swift
//  phlog
//
//  Created by Miroslav Taleiko on 14.12.2021.
//

import UIKit

public class ActionButton: UIButton {
    
    public var plusColor: UIColor = UIColor.white
    public var fillColor: UIColor = #colorLiteral(red: 0.04133618623, green: 0.04133618623, blue: 0.04133618623, alpha: 1)
    public var borderColor: UIColor = UIColor.darkGray
    
    private let shape = CAShapeLayer()
    private let plus = CAShapeLayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeShadow()
    }

    
    public override func draw(_ rect: CGRect) {
        
        // Shape
        shape.frame = self.bounds
        shape.lineWidth = Constants.shapeLineWidth
        shape.fillColor = fillColor.cgColor
        shape.strokeColor = borderColor.cgColor
        let center = CGPoint(x: halfWidth, y: halfHeight)
        let radius: CGFloat = min(bounds.width, bounds.height)
        
        let startAngle: CGFloat = 2 * .pi / 3
        let endAngle: CGFloat = .pi / 3
        
        shape.path = UIBezierPath(arcCenter: center,
                                  radius: radius / 2 - Constants.shapeLineWidth,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true).cgPath
        
        self.layer.addSublayer(shape)
        
        // Plus sign
        let plusWidth = min(bounds.width, bounds.height) * Constants.plusSizeFactor
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = Constants.plusLineWidth
        
        plusPath.move(to: CGPoint(x: halfWidth - plusWidth + Constants.pixelShift,
                                  y: halfHeight + Constants.pixelShift))
        
        plusPath.addLine(to: CGPoint(x: halfWidth + plusWidth + Constants.pixelShift,
                                     y: halfHeight + Constants.pixelShift))
        
        plusPath.move(to: CGPoint(x: halfWidth + Constants.pixelShift,
                                  y: halfHeight - plusWidth + Constants.pixelShift))
        
        plusPath.addLine(to: CGPoint(x: halfWidth + Constants.pixelShift,
                                     y: halfHeight + plusWidth + Constants.pixelShift))
        
        plus.path = plusPath.cgPath
        plus.strokeColor = plusColor.cgColor
        plus.lineWidth = Constants.plusLineWidth
        plus.borderColor = UIColor.cyan.cgColor
        plus.borderWidth = 1
        self.layer.addSublayer(plus)

        addTarget(self, action: #selector(onTap), for: .touchUpInside)
        
    }
    
    @objc private func onTap() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2, options: .curveEaseInOut) {
            self.transform = CGAffineTransform(translationX: 0, y: -10)
            self.shape.fillColor = UIColor.darkGray.withAlphaComponent(0.3).cgColor
        } completion: { _ in
            self.transform = .identity
            self.shape.fillColor = self.fillColor.cgColor
        }

    }
    
    private func makeShadow() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = Constants.shadowOpacity
        self.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.layer.shadowRadius = 4
        self.layer.shouldRasterize = true
    }
    
    private var halfWidth: CGFloat {
        return bounds.width / 2
    }
    
    private var halfHeight: CGFloat {
        return bounds.height / 2
    }
    
    private struct Constants {
        static let shapeLineWidth: CGFloat = 1
        static let plusLineWidth: CGFloat = 1
        static let pixelShift: CGFloat = 0.5
        static let plusSizeFactor: CGFloat = 0.2
        static let shadowOpacity: Float = 0.7
    }
}

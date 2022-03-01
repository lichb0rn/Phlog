//
//  Presentable.swift
//  phlog
//
//  Created by Miroslav Taleiko on 15.01.2022.
//

import UIKit

public protocol Presentable {
    func toPresentable() -> UIViewController
}


extension UIViewController: Presentable {
    public func toPresentable() -> UIViewController {
        return self
    }
}

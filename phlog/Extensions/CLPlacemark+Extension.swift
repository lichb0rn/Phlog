//
//  CLPlacemark+Extension.swift
//  phlog
//
//  Created by Miroslav Taleiko on 01.05.2022.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    func string() -> String {
        var line = ""
        line.add(text: self.subThoroughfare)
        line.add(text: self.thoroughfare, separatedBy: " ")
        line.add(text: self.locality, separatedBy: ", ")
        return line
    }
}

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}

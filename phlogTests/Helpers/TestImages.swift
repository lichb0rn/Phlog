//
//  TestImages.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 09.04.2022.
//

import UIKit

let testingSymbols: [String] = [
    "square.and.arrow.up",
    "square.and.arrow.up.fill",
    "square.and.arrow.up.circle",
    "square.and.arrow.up.circle.fill",
    "square.and.arrow.up.trianglebadge.exclamationmark",
    "square.and.arrow.down",
    "square.and.arrow.down.fill",
    "square.and.arrow.up.on.square",
    "square.and.arrow.up.on.square.fill",
    "square.and.arrow.down.on.square",
    "square.and.arrow.down.on.square.fill",
    "rectangle.portrait.and.arrow.right",
    "rectangle.portrait.and.arrow.right.fill",
    "pencil",
    "pencil.circle",
    "pencil.circle.fill",
    "pencil.slash",
    "square.and.pencil",
    "rectangle.and.pencil.and.ellipsis",
    "scribble",
    "scribble.variable",
    "highlighter",
    "pencil.and.outline",
    "pencil.tip",
    "pencil.tip.crop.circle",
    "pencil.tip.crop.circle.badge.plus",
    "pencil.tip.crop.circle.badge.minus",
    "pencil.tip.crop.circle.badge.arrow.forward",
    "lasso",
    "lasso.and.sparkles",
    "trash",
    "trash.fill",
    "trash.circle",
    "trash.circle.fill",
    "trash.square",
    "trash.square.fill",
    "trash.slash",
    "trash.slash.fill",
    "trash.slash.circle"
]

func testingImages() -> [String: UIImage] {
    var images: [String: UIImage] = [:]
    
    images = testingSymbols.reduce(into: [:]) { result, symbol in
        result[symbol] = UIImage(systemName: symbol)
    }
    return images
}

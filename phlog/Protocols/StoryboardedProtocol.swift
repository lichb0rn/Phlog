//
//  StoryboardedProtocol.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import Foundation
import UIKit

protocol Storyboarded {
    static var name: String { get }
    static func instantiate(from storyboardType: StoryboardType) -> Self
}

public enum StoryboardType: String {
    case feed = "Feed"
    case map = "MapViewController"
    case main = "Main"
    case detail = "DetailView"
}

extension Storyboarded where Self: UIViewController {
    
    static func instantiate(from storyboardType: StoryboardType) -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: Bundle.main)
        return storyboard.instantiateViewController(identifier: id) as! Self
    }
}


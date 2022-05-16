//
//  TabController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import UIKit
import PhotosUI

protocol TabViewActionControll: AnyObject {
    func tabViewActionButtonTapped(_ viewController: UIViewController)
}


class TabController: UITabBarController {
    
    weak var coordinator: TabViewActionControll?

    private var actionButtonWidth: CGFloat = 50
    private var actionButtonHeight: CGFloat = 50
    private var actionButton: ActionButton!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
        tabBar.backgroundColor = UIColor(named: "shadedBlack")
        configureButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tabBar.itemPositioning = .centered
        self.tabBar.itemSpacing = UIScreen.main.bounds.width / 3
    }
    
    private func configureButton() {
        let actionButton = ActionButton(frame: CGRect(x: tabBar.bounds.midX - 25,
                                                      y: tabBar.bounds.midY - 35,
                                                      width: actionButtonWidth,
                                                      height: actionButtonHeight))
        tabBar.addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func actionButtonTapped() {
        
        // Presenting the library
        coordinator?.tabViewActionButtonTapped(self)
    }
}

extension TabController: Storyboarded {
    static var name: String {
        return "TabController"
    }
}


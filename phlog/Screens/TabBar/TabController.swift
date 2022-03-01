//
//  TabController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.12.2021.
//

import UIKit
import PhotosUI

public protocol TabViewActionControll: AnyObject {
    func tabViewActionButtonTapped(_ viewController: UIViewController)
}


public class TabController: UITabBarController {
    
    public weak var coordinator: TabViewActionControll?

    // Creating a circle "plus" button
    private var actionButtonWidth: CGFloat = 55
    private var actionButtonHeight: CGFloat = 30
    private lazy var actionButton = ActionButton()
        
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
        configureButton()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tabBar.itemPositioning = .centered
        self.tabBar.itemSpacing = UIScreen.main.bounds.width / 3
    }
    
    private func configureButton() {
        tabBar.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: actionButtonHeight),
            actionButton.widthAnchor.constraint(equalToConstant: actionButtonWidth),
            actionButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor, constant: -20)
        ])
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func actionButtonTapped() {
        
        // Presenting the library
        actionButton.rotateImage()
        coordinator?.tabViewActionButtonTapped(self)
    }
}

extension TabController: Storyboarded {
    static var name: String {
        return "TabController"
    }
}


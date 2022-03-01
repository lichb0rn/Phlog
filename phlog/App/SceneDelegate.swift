//
//  SceneDelegate.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var router: MainRouter?
    var coordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        
        let mainRouter = MainRouter(window: window!)
        let mainCoordinator = MainCoordinator(router: mainRouter)
        mainCoordinator.start(animated: false, completion: nil)
            
        self.router = mainRouter
        self.coordinator = mainCoordinator
    }


}



import Foundation
import UIKit

class MapViewCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var router: Router
    private var phlogProvider: PhlogService
    
    private lazy var mapViewController = MapViewController.instantiate(from: .map)
    
    init(router: Router, phlogProvider: PhlogService) {
        self.router = router
        self.phlogProvider = phlogProvider
    }
    
    
    func start(animated: Bool, completion: (() -> Void)?) {
        router.present(mapViewController, animated: animated, completion: completion)
    }
 
}

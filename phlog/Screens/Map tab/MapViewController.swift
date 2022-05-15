import UIKit
import MapKit


class MapViewController: UIViewController {


    var viewModel: MapViewModel!

    @IBOutlet weak var mapView: MKMapView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.configure(mapView: mapView)
    }


    
}

extension MapViewController: Storyboarded {
    static var name: String {
        return "MapViewController"
    }
}

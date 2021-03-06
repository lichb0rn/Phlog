import UIKit
import MapKit


class MapViewController: UIViewController {

    var viewModel: MapViewModel!
    @IBOutlet weak var mapView: MKMapView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        mapView.register(PhlogAnnotationView.self, forAnnotationViewWithReuseIdentifier: PhlogAnnotationView.identifier)
        viewModel.configure(mapView: mapView)
    }
}

extension MapViewController: Storyboarded {
    static var name: String {
        return "MapViewController"
    }
}

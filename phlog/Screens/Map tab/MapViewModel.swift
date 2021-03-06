import UIKit
import MapKit
import CoreData


class MapViewModel: NSObject {

    var mapView: MKMapView!
    let phlogProvider: PhlogService

    private(set) var locations: [PhlogLocation] = []

    init(phlogProvider: PhlogService) {
        self.phlogProvider = phlogProvider
    }


    func configure(mapView: MKMapView) {
        self.mapView = mapView
        self.mapView.delegate = self
        updateLocations()

        if !locations.isEmpty {
            showLocations()
        }
    }

    func showLocations() {
        let region = region(for: locations)
        mapView.setRegion(region, animated: true)
    }

    func updateLocations() {
        mapView.removeAnnotations(locations)

        let fetchRequest = NSFetchRequest<PhlogLocation>()
        fetchRequest.entity = PhlogLocation.entity()
        do {
            locations = try phlogProvider.mainContext.fetch(fetchRequest)
            mapView.addAnnotations(locations)
        } catch { }
    }

    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion

        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)

            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)

                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
                latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
                longitude: topLeft.longitude -  (topLeft.longitude - bottomRight.longitude) / 2
            )

            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
                longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
}


//MARK: - MKMapViewDelegate
extension MapViewModel: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is PhlogLocation else { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PhlogAnnotationView.identifier, for: annotation) as? PhlogAnnotationView
        if annotationView == nil {
            annotationView = PhlogAnnotationView(annotation: annotation, reuseIdentifier: PhlogAnnotationView.identifier)
        }

        var image: UIImage
        if let imageData = (annotation as? PhlogLocation)?.phlog?.pictureThumbnail {
            image = UIImage(data: imageData) ?? UIImage(systemName: "camera")!
        } else {
            image = UIImage(systemName: "camera")!
        }
        annotationView?.setImage(image)

        return annotationView
    }
}

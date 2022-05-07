import Foundation
import CoreLocation
import Contacts
import Intents
import MapKit

class MockPlacemark: CLPlacemark {
    static let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(100), longitude: CLLocationDegrees(100))

    override init() {
        let mkPlacemark = MKPlacemark(coordinate: MockPlacemark.coordinate) as CLPlacemark
        super.init(placemark: mkPlacemark)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override static var supportsSecureCoding: Bool {
        return false
    }
    override var location: CLLocation? {
        return CLLocation(latitude: MockPlacemark.coordinate.latitude, longitude: MockPlacemark.coordinate.longitude)
    }
    override var postalAddress: CNPostalAddress?  {
        return nil
    }

    override var name: String? {
        return "Hogwarts"
    }
}

class MockGeocoder: CLGeocoder {

    var shouldFail: Bool = false
    var geocodingRequested: Bool = false
    var errorCode = CLError.Code.network
    override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        geocodingRequested = true

        guard  !shouldFail else {
            completionHandler(nil, NSError(domain: "mockgeocoder", code: errorCode.rawValue))
            return
        }

        let placemark = MockPlacemark()
        completionHandler([placemark], nil)

    }
}


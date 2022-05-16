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

    override var subThoroughfare: String? {
        return "Hogwarts School of Witchcraft and Wizardry"
    }

    override var thoroughfare: String? {
        return "Hogwarts Castle"
    }

    override var locality: String? {
        return "Scottish Highlands"
    }
}

class MockGeocoder: CLGeocoder {

    let placemark = MockPlacemark()
    static var mockPlacemarkString: String {
        return "Hogwarts School of Witchcraft and Wizardry Hogwarts Castle, Scottish Highlands"
    }
    var shouldFail: Bool = false
    var geocodingRequested: Bool = false
    var errorCode = CLError.Code.network
    override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        geocodingRequested = true

        guard  !shouldFail else {
            completionHandler(nil, NSError(domain: "mockgeocoder", code: errorCode.rawValue))
            return
        }

        completionHandler([placemark], nil)
    }
}


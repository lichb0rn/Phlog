import XCTest
import MapKit
@testable import phlog
import CoreData

class MapViewModelTests: XCTestCase {

    var sut: MapViewModel!
    var phlogProvider: PhlogService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let mockCoreData = MockCoreDataStack()
        phlogProvider = PhlogProvider(db: mockCoreData)
        sut = MapViewModel(phlogProvider: phlogProvider)
        sut.mapView = MKMapView()
    }

    override func tearDownWithError() throws {
        sut = nil
        phlogProvider = nil
        try super.tearDownWithError()
    }

    func givenLocations() {
        let location1 = phlogProvider.newLocation(latitude: 100, longitude: 100, placemark: nil, context: phlogProvider.mainContext)
        location1.placemark = MockPlacemark()

        let location2 = phlogProvider.newLocation(latitude: 150, longitude: 150, placemark: nil, context: phlogProvider.mainContext)
        location2.placemark = MockPlacemark()
        phlogProvider.saveChanges(context: phlogProvider.mainContext)
    }

    func whenDidLoad() {
        let mapView = MKMapView()
        sut.configure(mapView: mapView)
    }

    // MARK: - Tests
    func testViewModel_declaresMapViewDelegate() {
        XCTAssertTrue((sut as AnyObject) is MKMapViewDelegate)
    }

    func testViewModel_givenLocations_locationFetched() {
        givenLocations()

        sut.updateLocations()

        XCTAssertEqual(sut.locations.count, 2)
    }

    func testViewModel_givenLocations_annotatesMapView() {
        givenLocations()

        sut.updateLocations()

        XCTAssertEqual(sut.mapView.annotations.count, 2)
    }
}

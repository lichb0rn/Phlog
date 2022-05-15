import XCTest
@testable import phlog

class MapViewControllerTests: XCTestCase {

    var sut: MapViewController!
    var viewModel: MapViewModel!
    var phlogProvier: PhlogProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let mockCoreData = MockCoreDataStack()
        phlogProvier = PhlogProvider(db: mockCoreData)
        viewModel = MapViewModel(phlogProvider: phlogProvier)

        sut = MapViewController.instantiate(from: .map)
        sut.loadViewIfNeeded()
        viewModel.configure(mapView: sut.mapView)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        sut = nil
        viewModel = nil
        phlogProvier = nil
    }

}

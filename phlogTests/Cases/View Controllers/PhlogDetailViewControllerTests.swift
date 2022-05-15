import XCTest
@testable import phlog

class PhlogDetailViewControllerTests: XCTestCase {

    var sut: PhlogDetailViewController!
    var phlogProvider: PhlogService!
    var locationProvider: LocationProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let mockCoreData = MockCoreDataStack()
        phlogProvider = PhlogProvider(db: mockCoreData)
        let mockLocationManager = MockLocationManager()
        let mockGeocoder = MockGeocoder()
        locationProvider = LocationProvider(locationManager: mockLocationManager, geocoder: mockGeocoder)

        sut = PhlogDetailViewController.instantiate(from: .detail)
    }

    override func tearDownWithError() throws {
        sut = nil
        phlogProvider = nil
        locationProvider = nil
        try super.tearDownWithError()
    }

    func given_viewModel_withOutPhlog() {
        let viewModel = DetailViewModel(phlogProvider: phlogProvider, locationProvider: locationProvider)
        sut.viewModel = viewModel
    }

    func given_viewModel_withPhlog() {
        let phlog = PhlogPost(context: phlogProvider.mainContext)
        phlog.dateCreated = Date(timeIntervalSince1970: 10000)
        let picture = phlogProvider.newPicture(withID: testingSymbols[0], context: phlogProvider.mainContext)
        picture.pictureData = UIImage(systemName: testingSymbols[0])!.pngData()
        phlog.picture = picture
        phlog.body = "Testing Non Empty ViewModel"
        let location = phlogProvider.newLocation(latitude: 100, longitude: 100, placemark: nil, context: phlogProvider.mainContext)
        phlog.location = location
        let placemark = MockPlacemark()
        phlog.location?.placemark = placemark

        let viewModel = DetailViewModel(phlogProvider: phlogProvider, phlog: phlog, locationProvider: locationProvider)
        sut.viewModel = viewModel

        phlogProvider.saveChanges(context: phlogProvider.mainContext)
    }

    func whenDidAppear() {
        sut.loadViewIfNeeded()
        sut.viewModel?.didAppear()
    }

    // MARK: - Tests

    func testController_whenDidAppear_withOutPhlog_hasCorrectUIState() throws {
        let currentDate = Date().formatted(date: .long, time: .omitted)

        given_viewModel_withOutPhlog()
        whenDidAppear()

        let imageSectionHeaderView = try XCTUnwrap(sut.tableView(sut.tableView, viewForHeaderInSection: 0) as? UIImageView)
        let locationSectionTitle = sut.tableView(sut.tableView, titleForHeaderInSection: 1)
        XCTAssertEqual(sut.title, currentDate)
        XCTAssertNil(imageSectionHeaderView.image)
        XCTAssertNil(locationSectionTitle)
        XCTAssertEqual(sut.textView.text, "")
    }

    func testController_whenDidAppear_withPhlog_hasCorrectUIState() throws {
        let dateString = Date(timeIntervalSince1970: 10000).formatted(date: .long, time: .omitted)

        given_viewModel_withPhlog()
        whenDidAppear()
        let placemarkString = MockGeocoder.mockPlacemarkString
        let pictureData = sut.viewModel.image?.pngData()

        XCTAssertEqual(sut.title, dateString)
        let imageSectionHeaderView = try XCTUnwrap(sut.tableView(sut.tableView, viewForHeaderInSection: 0) as? UIImageView)
        let locationSectionTitle = sut.tableView(sut.tableView, titleForHeaderInSection: 1)
        XCTAssertEqual(imageSectionHeaderView.image?.pngData(), pictureData)
        XCTAssertEqual(locationSectionTitle, placemarkString)
    }
}

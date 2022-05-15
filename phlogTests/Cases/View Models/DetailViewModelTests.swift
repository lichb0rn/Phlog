//
//  DetailViewModelTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 09.04.2022.
//

import XCTest
import CoreData
import Combine
import CoreLocation
@testable import phlog

class DetailViewModelTests: XCTestCase {
    
    var sut: DetailViewModel!
    var phlogProvider: PhlogProvider!
    var mockImageProvider: MockImageProvider!
    var mockCoreData: MockCoreDataStack!
    var mockLocationManager: MockLocationManager!
    var mockGeocoder: MockGeocoder!
    var locationProvider: LocationService!
    
    var phlog: PhlogPost!
    var targetSize: CGSize = CGSize(width: 100, height: 100)
    var cancellable: Set<AnyCancellable> = []
    
    var images = testingImages()


    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockCoreData = MockCoreDataStack()
        phlogProvider = PhlogProvider(db: mockCoreData)
        mockImageProvider = MockImageProvider()
        mockLocationManager = MockLocationManager()
        mockGeocoder = MockGeocoder()
        locationProvider = LocationProvider(locationManager: mockLocationManager, geocoder: mockGeocoder)
        phlog = phlogProvider.newPhlog(context: phlogProvider.mainContext)
        sut = DetailViewModel(phlogProvider: phlogProvider,
                              phlog: phlog,
                              imageProvider: mockImageProvider,
                              locationProvider: locationProvider)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        phlog = nil
        mockImageProvider = nil
        phlogProvider = nil
        mockCoreData = nil
        locationProvider = nil
        mockLocationManager = nil
        mockGeocoder = nil
        cancellable.removeAll()
        try super.tearDownWithError()
    }

    @discardableResult
    func givenPhlog() -> PhlogPost {
        let testImage = UIImage(systemName: testingSymbols[0])!.resizeTo(size: targetSize)
        let pictureData = testImage!.pngData()
        phlog.picture = phlogProvider.newPicture(withID: "123456789", context: phlogProvider.mainContext)
        phlog.picture?.pictureData = pictureData
        phlog.body = "Testing"
        return phlog
    }

    func fetchPhlog(withID id: UUID) -> PhlogPost? {
        let fetchRequest = PhlogPost.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        fetchRequest.predicate = predicate
        let result = try? phlogProvider.mainContext.fetch(fetchRequest)
        return result?.first
    }
    
    // --------------------------------------
    // MARK: - Tests
    // --------------------------------------
    func test_givenPhlog_imageLoadedFromLocalStore() {
        givenPhlog()
        let expectation = expectation(description: "image not loaded")
        var img: UIImage?
        sut.$image
            .dropFirst()
            .sink { image in
                img = image
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        sut.didAppear()
        
        waitForExpectations(timeout: 0.2)
        XCTAssertNotNil(sut.image)
        XCTAssertEqual(img?.pngData(), sut.image?.pngData())
    }
    
    func test_givePhlog_textLoadedFromLocalStore() throws {
        givenPhlog()
        sut = DetailViewModel(phlogProvider: phlogProvider, phlog: phlog, locationProvider: locationProvider)
        
        let text = sut.body
        
        XCTAssertNotNil(sut.body)
        XCTAssertEqual(text, "Testing")
    }

    func test_givenPhlog_dataSaved() {
        let expectedPhlog = givenPhlog()
        sut = DetailViewModel(phlogProvider: phlogProvider, phlog: expectedPhlog, locationProvider: locationProvider)

        sut.save()

        let fetchedPhlog = fetchPhlog(withID: expectedPhlog.id)
        let unwrapped = try! XCTUnwrap(fetchedPhlog)
        XCTAssertEqual(expectedPhlog.id, unwrapped.id)
    }


    func test_requestedImageUpdate() {
        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
        let img = mockImageProvider.images["trash.slash.circle"]?.resizeTo(size: size)

        sut.updatePhoto(with: "trash.slash.circle")
        
        XCTAssertNotNil(sut.image)
        XCTAssertEqual(img?.pngData(), sut.image?.pngData())
    }
    
    func test_whenEmpty_isMenuActiveFalse() {
        XCTAssertFalse(sut.isMenuActive)
    }
    
    func test_givenImage_isMenuActiveTrue() {
        sut.updatePhoto(with: "trash.slash.circle")
        
        XCTAssertTrue(sut.isMenuActive)
    }


    // MARK: - Location tests
    func test_givenLocation_coordinatesReceived() throws {
        let phlog = sut.phlog
        sut.addLocation()
        expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                    object: phlog.managedObjectContext) { _ in
            return true
        }

        mockLocationManager.sendLocation()

        waitForExpectations(timeout: 1)
        let expectedLocation = try XCTUnwrap(phlog.location)
        XCTAssertEqual(expectedLocation.coordinate.latitude,
                       mockLocationManager.mockLocation.coordinate.latitude,
                       accuracy: 0.000_001)
        XCTAssertEqual(expectedLocation.coordinate.longitude,
                       mockLocationManager.mockLocation.coordinate.longitude,
                       accuracy: 0.000_001)

    }

    func test_givenPlacemark_placemarkSaved() throws {
        let phlog = sut.phlog
        let phlogLocation = PhlogLocation(context: phlog.managedObjectContext!)
        phlog.location = phlogLocation
        sut.addLocation()
        expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                    object: phlog.managedObjectContext) { _ in
            return true
        }

        locationProvider.startGeocoding(mockLocationManager.mockLocation)

        waitForExpectations(timeout: 1)

        XCTAssertNotNil(phlogLocation.placemark)
        XCTAssertEqual(phlogLocation.placemark?.name, mockGeocoder.placemark.name)
    }

    func test_givenPlacemark_placemarkStringPublished() {
        let phlog = sut.phlog
        let phlogLocation = PhlogLocation(context: phlog.managedObjectContext!)
        phlog.location = phlogLocation
        let expectation = expectation(description: "placemark received")
        var receivedAddress = ""
        sut.$address
            .compactMap { $0 }
            .sink(receiveValue: { address in
                receivedAddress = address
                expectation.fulfill()
            })
            .store(in: &cancellable)
        sut.addLocation()
        locationProvider.startGeocoding(mockLocationManager.mockLocation)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedAddress, MockGeocoder.mockPlacemarkString)
    }
}

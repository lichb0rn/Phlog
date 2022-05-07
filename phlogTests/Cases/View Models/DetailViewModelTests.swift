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
        phlog = phlogProvider.newPhlog(context: phlogProvider.mainContext)
        sut = DetailViewModel(phlogProvider: phlogProvider,
                              phlog: phlog,
                              imageProvider: mockImageProvider,
                              locationProvider: mockLocationManager)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        phlog = nil
        mockImageProvider = nil
        phlogProvider = nil
        mockCoreData = nil
        mockLocationManager = nil
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
        sut = DetailViewModel(phlogProvider: phlogProvider, phlog: phlog)
        
        let text = sut.body
        
        XCTAssertNotNil(sut.body)
        XCTAssertEqual(text, "Testing")
    }

    func test_givenPhlog_dataSaved() {
        let expectedPhlog = givenPhlog()
        sut = DetailViewModel(phlogProvider: phlogProvider, phlog: expectedPhlog)

        sut.save()

        let fetchedPhlog = fetchPhlog(withID: expectedPhlog.id)
        let unwrapped = try! XCTUnwrap(fetchedPhlog)
        XCTAssertEqual(expectedPhlog.id, unwrapped.id)
    }


    func test_requestedImageUpdate() {
        let img = mockImageProvider.images["trash.slash.circle"]?.resizeTo(size: targetSize)

        sut.updatePhoto(with: "trash.slash.circle", size: targetSize)
        
        XCTAssertNotNil(sut.image)
        XCTAssertEqual(img?.pngData(), sut.image?.pngData())
    }
    
    func test_whenEmpty_isMenuActiveFalse() {
        XCTAssertFalse(sut.isMenuActive)
    }
    
    func test_givenImage_isMenuActiveTrue() {
        sut.updatePhoto(with: "trash.slash.circle", size: targetSize)
        
        XCTAssertTrue(sut.isMenuActive)
    }
    
    func test_givenPhlog_locationSaved() {
        let expectedLatitude = mockLocationManager.mockLocation.coordinate.latitude
        let expectedLongitude = mockLocationManager.mockLocation.coordinate.longitude
        let phlog = givenPhlog()
        mockLocationManager.sendLocation()

        sut.save()

        let fetchRequest = PhlogLocation.fetchRequest()
//        fetchRequest.predicate = NSPredicate(
    }
}

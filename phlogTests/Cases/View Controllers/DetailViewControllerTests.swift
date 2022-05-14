//
//  DetailViewControllerTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 09.04.2022.
//

import XCTest
@testable import phlog

class DetailViewControllerTests: XCTestCase {
    
    var sut: DetailViewController!
    var phlogProvider: PhlogService!
    var locationProvider: LocationProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()

        let mockCoreData = MockCoreDataStack()
        phlogProvider = PhlogProvider(db: mockCoreData)
        let mockLocationManager = MockLocationManager()
        let mockGeocoder = MockGeocoder()
        locationProvider = LocationProvider(locationManager: mockLocationManager, geocoder: mockGeocoder)

        sut = DetailViewController.instantiate(from: .detail)
    }

    override func tearDownWithError() throws {
        sut = nil
        phlogProvider = nil
        locationProvider = nil
        try super.tearDownWithError()
    }

    func givenEmptyViewModel() {
        let viewModel = DetailViewModel(phlogProvider: phlogProvider, locationProvider: locationProvider)
        sut.viewModel = viewModel
    }
    
    func givenNonEmptyViewModel() {
        let phlog = PhlogPost(context: phlogProvider.mainContext)
        phlog.dateCreated = Date(timeIntervalSince1970: 10000)
        let picture = phlogProvider.newPicture(withID: testingSymbols[0], context: phlogProvider.mainContext)
        picture.pictureData = UIImage(systemName: testingSymbols[0])!.pngData()
        phlog.picture = picture
        phlog.body = "Testing Non Empty ViewModel"
            
        let viewModel = DetailViewModel(phlogProvider: phlogProvider, phlog: phlog, locationProvider: locationProvider)
        sut.viewModel = viewModel
        
        phlogProvider.saveChanges(context: phlogProvider.mainContext)
    }
    
    func whenDidAppear() {
        sut.loadViewIfNeeded()
        sut.viewModel?.didAppear()
    }
    
    func testController_whenDidAppear_noData_hasCorrectOutlets() {
        let currentDate = Date().formatted(date: .long, time: .omitted)
        let placeholder = UIImage(named: "ImagePlaceholder")!.pngData()
        
        givenEmptyViewModel()
        whenDidAppear()
        
        XCTAssertEqual(sut.title, currentDate)
        XCTAssertEqual(sut.imageView.image?.pngData(), placeholder)
        XCTAssertEqual(sut.textView.text, "")
//        XCTAssertEqual(sut.locationLabel.text, "")
    }

    func testController_whenDidAppear_noData_locationOutlet_isHidden() {
        givenEmptyViewModel()
        whenDidAppear()

//        XCTAssertTrue(sut.locationLabel.isHidden)
    }
    
    func testController_whenDidAppear_withData_hasCorrectOutlets() {
        let dateString = Date(timeIntervalSince1970: 10000).formatted(date: .long, time: .omitted)
        
        givenNonEmptyViewModel()
        whenDidAppear()
        
        XCTAssertEqual(sut.title, dateString)
        XCTAssertNotNil(sut.imageView.image)
        XCTAssertEqual(sut.textView.text, "Testing Non Empty ViewModel")
    }


}

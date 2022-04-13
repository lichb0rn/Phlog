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
    var phlogManager: PhlogManager!
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = DetailViewController.instantiate(from: .detail)
        let mockCoreData = MockCoreDataStack()
        phlogManager = PhlogManager(db: mockCoreData)

    }

    override func tearDownWithError() throws {
        sut = nil
        phlogManager = nil
        try super.tearDownWithError()
    }

    func whenEmptyViewModelGiven() {
        let viewModel = DetailViewModel(phlogManager: phlogManager)
        sut.viewModel = viewModel
    }
    
    func whenNonEmptyViewModelGiven() {
        let phlog = PhlogPost(context: phlogManager.mainContext)
        phlog.dateCreated = Date(timeIntervalSince1970: 10000)
        let picture = phlogManager.newPicture(withID: testingSymbols[0], context: phlogManager.mainContext)
        picture.pictureData = UIImage(systemName: testingSymbols[0])!.pngData()
        phlog.picture = picture
        phlog.body = "Testing Non Empty ViewModel"
            
        let viewModel = DetailViewModel(phlogManager: phlogManager, phlog: phlog)
        sut.viewModel = viewModel
        
        phlogManager.saveChanges(context: phlogManager.mainContext)
    }
    
    func whenLoaded() {
        sut.loadViewIfNeeded()
        sut.viewModel?.fetchImage()
    }
    
    func testController_whenEmptyLoaded_hasCorrectOutlets() {
        let currentDate = Date().formatted(date: .long, time: .omitted)
        let placeholder = UIImage(named: "ImagePlaceholder")!.pngData()
        
        whenEmptyViewModelGiven()
        whenLoaded()
        
        XCTAssertEqual(sut.title, currentDate)
        XCTAssertEqual(sut.imageView.image?.pngData(), placeholder)
        XCTAssertEqual(sut.textView.text, "")
    }
    
    
    func testController_whenLoadedWithData_hasCorrectOutlets() {
        let dateString = Date(timeIntervalSince1970: 10000).formatted(date: .long, time: .omitted)
        
        whenNonEmptyViewModelGiven()
        whenLoaded()
        
        XCTAssertEqual(sut.title, dateString)
        XCTAssertNotNil(sut.imageView.image)
        XCTAssertEqual(sut.textView.text, "Testing Non Empty ViewModel")
    }
    
    
    func testController_whenUpdated_hasCorrectOutlets() {
        whenEmptyViewModelGiven()
        
    
    }
}

//
//  DetailViewModelTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 09.04.2022.
//

import XCTest
@testable import phlog

class DetailViewModelTests: XCTestCase {
    
    var sut: DetailViewModel!
    var phlogManager: PhlogManager!
    var phlog: PhlogPost!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let mockCoreData = MockCoreDataStack()
        phlogManager = PhlogManager(db: mockCoreData)
        phlog = phlogManager.newPhlog(context: phlogManager.mainContext)
        sut = DetailViewModel(phlogManager: phlogManager, phlog: phlog)
    }

    override func tearDownWithError() throws {
        sut = nil
        phlogManager = nil
        try super.tearDownWithError()
    }
    
    
    func addDataToPhlog() {
        let pictureData = UIImage(systemName: testingSymbols[0])!.pngData()
        phlog.picture = PhlogPicture(context: phlogManager.mainContext)
        phlog.picture?.pictureData = pictureData
        phlog.body = "Testing"
    }
    
//    func testWhenFetch_imageLoadedFromCoreData() {
//        addDataToPhlog()
//        phlogManager.saveChanges()
//
//        sut.fetchImage()
//
//        XCTAssertEqual(sut.image?.pngData(), pictureData)
//    }
}

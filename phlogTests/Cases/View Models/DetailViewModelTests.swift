//
//  DetailViewModelTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 09.04.2022.
//

import XCTest
import CoreData
@testable import phlog

class DetailViewModelTests: XCTestCase {
    
    var sut: DetailViewModel!
    var phlogProvider: PhlogProvider!
    var mockImageProvider: MockImageProvider!
    var mockCoreData: MockCoreDataStack!
    
    var phlog: PhlogPost!
    var targetSize: CGSize = CGSize(width: 100, height: 100)
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockCoreData = MockCoreDataStack()
        phlogProvider = PhlogProvider(db: mockCoreData)
        mockImageProvider = MockImageProvider()
        phlog = phlogProvider.newPhlog(context: phlogProvider.mainContext)
        sut = DetailViewModel(phlogProvider: phlogProvider, phlog: phlog, imageProvider: mockImageProvider)
    }

    override func tearDownWithError() throws {
        sut = nil
        phlog = nil
        mockImageProvider = nil
        phlogProvider = nil
        mockCoreData = nil
        try super.tearDownWithError()
    }
    
    
    func givenPhlog() {
        let testImage = UIImage(systemName: testingSymbols[0])!.resizeTo(size: targetSize)
        let pictureData = testImage!.pngData()
        phlog.picture = phlogProvider.newPicture(withID: "123456789", context: phlogProvider.mainContext)
        phlog.picture?.pictureData = pictureData
        phlog.body = "Testing"
    }
    
    func test_givenPhlog_imageLoadedFromCoreData() {
        givenPhlog()
        
        sut.fetchImage(targetSize: CGSize(width: 100, height: 100))

        XCTAssertNotNil(sut.image)
    }
    
    func test_whenRequested_imageFetchedFormLibrary() {
        phlog.picture = phlogProvider.newPicture(withID: UUID().uuidString, context: phlogProvider.mainContext)
        
        sut.fetchImage(targetSize: targetSize)
        
        XCTAssertNotNil(sut.image)
    }
    
    
    func test_whenUpdate_phlogPictureUpdatedWithNewID() {
        givenPhlog()
        let newId = "987654321"
        
        sut.updatePhoto(with: newId)
        sut.save()
        
        let picutre = try! phlogProvider.mainContext.existingObject(with: phlog.picture!.objectID) as! PhlogPicture
        XCTAssertEqual(newId, picutre.pictureIdentifier)
    }
}

//
//  FeedViewControllerTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 09.04.2022.
//

import XCTest
@testable import phlog

class FeedViewControllerTests: XCTestCase {

    var sut: FeedViewContoller!
    var phlogManager: PhlogManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = FeedViewContoller.instantiate(from: .feed)
        let mockCoreData = MockCoreDataStack()
        phlogManager = PhlogManager(db: mockCoreData)
        sut.phlogManager = phlogManager
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
        phlogManager = nil
        try super.tearDownWithError()
    }

    
    func whenDidAppear() {
        sut.viewDidAppear(false)
    }
    
    func whenBackendHasOnePhlog() {
        let image = UIImage(systemName: testingSymbols[0])!
        let context = phlogManager.mainContext
        let phlog = phlogManager.newPhlog(context: context)
        phlog.picture = PhlogPicture(context: context)
        phlog.picture?.pictureData = image.pngData()
        phlog.pictureThumbnail = image.resizeTo(size: CGSize(width: 40, height: 40))?.pngData()
        phlogManager.saveChanges(context: context)
    }
    
    func whenBackendHasPhlogs() {
        let images = testingImages()
        let context = phlogManager.mainContext
        images.forEach { key, value in
            let phlog = phlogManager.newPhlog(context: context)
            let picture = phlogManager.newPicture(withID: key, context: context)
            picture.pictureData = value.pngData()
            phlog.picture = picture
            phlog.pictureThumbnail = value.resizeTo(size: CGSize(width: 40, height: 40))?.pngData()
            
        }
        phlogManager.saveChanges(context: context)
    }
    
    
    func testController_whenFreshLoaded_collectionViewIsEmpty() {
        whenDidAppear()
        
        let items = sut.collectionView.numberOfItems(inSection: 0)
        
        XCTAssertEqual(items, 0)
    }
    
    
    func testController_whenLoadedWithData_collectionViewIsNotEmpty() {
        whenBackendHasPhlogs()
        whenDidAppear()
        
        let itemsInCollectionView = sut.collectionView.numberOfItems(inSection: 0)
        XCTAssertEqual(itemsInCollectionView, testingSymbols.count)
    }
}

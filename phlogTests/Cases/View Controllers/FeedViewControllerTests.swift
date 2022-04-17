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
    var phlogProvider: PhlogService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = FeedViewContoller.instantiate(from: .feed)
        let mockCoreData = MockCoreDataStack()
        phlogProvider = PhlogProvider(db: mockCoreData)
        sut.phlogProvider = phlogProvider
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
        phlogProvider = nil
        try super.tearDownWithError()
    }

    
    func whenDidAppear() {
        sut.viewDidAppear(false)
    }
    
    func whenBackendHasOnePhlog() {
        let image = UIImage(systemName: testingSymbols[0])!
        let context = phlogProvider.mainContext
        let phlog = phlogProvider.newPhlog(context: context)
        phlog.picture = PhlogPicture(context: context)
        phlog.picture?.pictureData = image.pngData()
        phlog.pictureThumbnail = image.resizeTo(size: CGSize(width: 40, height: 40))?.pngData()
        phlogProvider.saveChanges(context: context)
    }
    
    func whenBackendHasPhlogs() {
        let images = testingImages()
        let context = phlogProvider.mainContext
        images.forEach { key, value in
            let phlog = phlogProvider.newPhlog(context: context)
            let picture = phlogProvider.newPicture(withID: key, context: context)
            picture.pictureData = value.pngData()
            phlog.picture = picture
            phlog.pictureThumbnail = value.resizeTo(size: CGSize(width: 40, height: 40))?.pngData()
            
        }
        phlogProvider.saveChanges(context: context)
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

//
//  PhlogManagerTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 01.04.2022.
//

import XCTest
import CoreData
import CoreLocation
@testable import phlog

class PhlogProviderTests: XCTestCase {
    
    var sut: PhlogProvider!
    var service: PhlogService {
        sut as PhlogService
    }
    var mockCoreData: MockCoreDataStack!

    let mockLocation = CLLocation(latitude: 100.0, longitude: 100.0)

    // MARK: - Lifecycle
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockCoreData = MockCoreDataStack()
        sut = PhlogProvider(db: mockCoreData)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockCoreData = nil
        try super.tearDownWithError()
    }
    
    @discardableResult
    func givenPhlog(context: NSManagedObjectContext) -> PhlogPost {
        let body = UUID().uuidString
        let newPhlog = sut.newPhlog(context: context)
        newPhlog.body = body
        let pictureID = UUID().uuidString
        let newPicture = sut.newPicture(withID: pictureID, context: context)
        newPhlog.picture = newPicture
        return newPhlog
    }
    
    
    // MARK: - PhlogService - Tests
    func test_conformsTo_PhlogService() {
        XCTAssertTrue((sut as AnyObject) is PhlogService)
    }
    
    func test_declares_newPhlog() {
        _ = service.newPhlog(context: sut.mainContext)
    }
    
    func test_declares_newPicture() {
        let pictureIdentifier = UUID().uuidString
        let context = sut.mainContext
        
        _ = service.newPicture(withID: pictureIdentifier, context: context)
    }

    func test_declares_newLocation() {
        let context = sut.makeChildContext()

        _ = service.newLocation(latitude: 22.2, longitude: 22.2, placemark: nil, context: context)
    }

    func test_declaresSave() {
        let context = sut.mainContext
        
        service.saveChanges(context: context)
    }
    
    func test_declaresRemove() {
        let newPhlog = sut.newPhlog(context: sut.mainContext)
        sut.saveChanges(context: sut.mainContext)
        
        service.remove(newPhlog)
    }
    
    // MARK: Methods - Tests
    func testChildContext_whenCreated_hasMainParent() {
        let mainContext = sut.mainContext
        
        let childContext = sut.makeChildContext()
        
        XCTAssertEqual(mainContext, childContext.parent)
    }
    
    func test_createNewPhlog() {
        let context = sut.makeChildContext()
        
        let testPhlog = sut.newPhlog(context: context)
        
        XCTAssertNil(testPhlog.body, "New phlog body should be nil")
        XCTAssertNil(testPhlog.pictureThumbnail, "New phlog thumbnail should be nil")
        XCTAssertNil(testPhlog.picture, "New phlog picture should be nil")
    }
    
    func test_createNewPicture() {
        let context = sut.makeChildContext()
        let pictureId = UUID().uuidString
        
        let newPicture = sut.newPicture(withID: pictureId, context: context)
        
        XCTAssertEqual(newPicture.pictureIdentifier, pictureId, "New picture ID is not equal to given ID")
    }
    

    func test_createNewLocation() {
        let context = sut.makeChildContext()

        let location = sut.newLocation(latitude: mockLocation.coordinate.latitude,
                                       longitude: mockLocation.coordinate.longitude,
                                       placemark: nil,
                                       context: context)

        XCTAssertEqual(location.latitude, mockLocation.coordinate.latitude)
        XCTAssertEqual(location.longitude, mockLocation.coordinate.longitude)
        XCTAssertNil(location.placemark)
    }

    func testChildContext_whenHasChanges_isSaved() {
        let context = sut.makeChildContext()
        givenPhlog(context: context)
        
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: sut.mainContext) { _ in
            return true
        }
        
        sut.saveChanges(context: context)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Could not save child context")
        }
    }
    
    
    func test_whenHasObject_removeCalled() {
        let context = sut.mainContext
        let phlog = givenPhlog(context: context)
        let id = phlog.objectID
        sut.saveChanges(context: context)
        
        sut.remove(phlog)
        
        XCTAssertThrowsError(try context.existingObject(with: id))
    }
    
    func test_whenNoChanges_removeCalled() {
        let childContext = service.makeChildContext()
        let newPhlog = givenPhlog(context: childContext)
        
        sut.remove(newPhlog)
        
        XCTAssertFalse(mockCoreData.fatalErrored)
    }

}

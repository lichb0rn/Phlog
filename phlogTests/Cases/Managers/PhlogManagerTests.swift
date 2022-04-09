//
//  PhlogManagerTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 01.04.2022.
//

import XCTest
@testable import phlog

class PhlogManagerTests: XCTestCase {
    
    var sut: PhlogManager!
    var coreData: MockCoreDataStack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        coreData = MockCoreDataStack()
        sut = PhlogManager(db: coreData)
    }

    override func tearDownWithError() throws {
        sut = nil
        coreData = nil
        try super.tearDownWithError()
    }
    
    func testCreate_NewPhog() {
        let context = sut.childContext()
        
        let testPhlog = sut.newPhlog(context: context)
        
        
        XCTAssertNil(testPhlog.body, "New phlog body should be nil")
        XCTAssertNil(testPhlog.pictureThumbnail, "New phlog thumbnail should be nil")
        XCTAssertNil(testPhlog.picture, "New phlog picture should be nil")
    }
    
    func testCreate_NewPicture() {
        let context = sut.childContext()
        let pictureId = UUID().uuidString
        
        let newPicture = sut.newPicture(with: pictureId, context: context)
        
        XCTAssertEqual(newPicture.pictureIdentifier, pictureId, "New picture ID is not equal to given ID")
    }
    
    func testMainContext_whenHasChanges_IsSaved() {
        let context = sut.childContext()
        let body = UUID().uuidString
        let newPhlog = sut.newPhlog(context: context)
        newPhlog.body = body
        let pictureID = UUID().uuidString
        let newPicture = sut.newPicture(with: pictureID, context: context)
        newPhlog.picture = newPicture
        
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: coreData.mainContext) { _ in
            return true
        }
        
        sut.saveChanges(context)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
}

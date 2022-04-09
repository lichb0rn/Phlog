//
//  JournalManagerTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 01.04.2022.
//

import XCTest
@testable import phlog

class JournalManagerTests: XCTestCase {
    
    var sut: JournalManager!
    var coreData: MockCoreDataStack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        coreData = MockCoreDataStack()
        sut = JournalManager(db: coreData)
    }

    override func tearDownWithError() throws {
        sut = nil
        coreData = nil
        try super.tearDownWithError()
    }
    
}

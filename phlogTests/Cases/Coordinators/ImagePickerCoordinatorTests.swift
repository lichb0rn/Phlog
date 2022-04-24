//
//  ImagePickerCoordinatorTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 13.04.2022.
//

import XCTest
@testable import phlog
import PhotosUI

class ImagePickerCoordinatorTests: XCTestCase {
    
    var sut: ImagePickerCoordinator!
    var navigationRouter: Router!

    override func setUpWithError() throws {
        try super.setUpWithError()
        navigationRouter = NavigationRouter(navigationController: UINavigationController())
        sut = ImagePickerCoordinator(router: navigationRouter)
    }

    override func tearDownWithError() throws {
        sut = nil
        navigationRouter = nil
        try super.tearDownWithError()
    }

    func test_whenStart_pickerViewControllerIsShowed() {
        sut.start(animated: false, completion: nil)
        
        XCTAssertTrue(sut.toPresentable() is PHPickerViewController)
    }
    
    func test_whenDismissed_completionCalled() {
        let expectetation = expectation(description: "didn't call completion")
        
        sut.start(animated: false) {
            expectetation.fulfill()
        }
        sut.dismiss(animated: false)
        
        wait(for: [expectetation], timeout: 0.1)
    }
    
    func test_whenPickerCalled_assetIsSet() {
        
    }
    
    func test_whenNotAuthorized_generatesAlert() {
        
    }
    
}

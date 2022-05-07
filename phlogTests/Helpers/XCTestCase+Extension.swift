import XCTest

extension XCTestCase {
    
    func wait(for duration: TimeInterval) {
        let exp = expectation(description: "wait")
        
        let timeout = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: timeout) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: duration + 0.5)
    }
}

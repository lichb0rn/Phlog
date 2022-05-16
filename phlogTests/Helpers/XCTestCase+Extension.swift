import XCTest
import Combine
import CoreLocation

extension XCTestCase {
    func waitAndObserve<T: Publisher>(for publisher: T,
                                      afterChange change: () -> Void,
                                      waitFor delay: TimeInterval = 1,
                                      file: StaticString = #file,
                                      line: UInt = #line) -> (T.Output?, T.Failure?) {
        let expectation = expectation(description: "Wait for publisher in \(#file)")

        var receivedValue: T.Output?
        var receivedError: T.Failure?
        let token = publisher
            .sink { result in
                switch result {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { value in
                receivedValue = value
            }

        change()
        wait(for: [expectation], timeout: delay)
        token.cancel()

        return (receivedValue, receivedError)
    }
}


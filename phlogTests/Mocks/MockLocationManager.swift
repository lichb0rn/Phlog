//
//  MockLocationManager.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 30.04.2022.
//

import Foundation
import CoreLocation
@testable import phlog

class MockLocationManager: CLLocationManager {
    //+37.33233141,-122.03121860
    var mockLocation = CLLocation(
        coordinate: CLLocationCoordinate2D(latitude: 100, longitude: 100),
        altitude: 1,
        horizontalAccuracy: 1,
        verticalAccuracy: 1,
        timestamp: .now)
    override var location: CLLocation? {
        return mockLocation
    }

    
    override init() {
        super.init()
    }
    
    var isUpdating: Bool = false
    override func startUpdatingLocation() {
        isUpdating = true
    }
    
    override func stopUpdatingLocation() {
        self.isUpdating = false
    }
    
    var authStatus: CLAuthorizationStatus = .authorizedWhenInUse
    override var authorizationStatus: CLAuthorizationStatus {
        return authStatus
    }
    var authorizationRequested: Bool = false
    override func requestWhenInUseAuthorization() {
        authorizationRequested = true
    }
    

    var error: CLError = .init(CLError.denied)
    func failWithError() {
        delegate?.locationManager?(self, didFailWithError: error )
    }
    
    func sendLocation() {
        delegate?.locationManager?(self, didUpdateLocations: [mockLocation])
    }
}

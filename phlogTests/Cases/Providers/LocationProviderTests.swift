//
//  LocationProviderTests.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 07.05.2022.
//

import XCTest
import CoreLocation
import Combine
@testable import phlog

class LocationProviderTests: XCTestCase {

    var sut: LocationProvider!
    var service: LocationService {
        return sut as LocationService
    }
    var mockLocationManager: MockLocationManager!
    var mockGeocoder: MockGeocoder!
    var mockPlacemark: MockPlacemark!
    var mockLocation = CLLocation(latitude: 100, longitude: 100)
    var cancellable = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockLocationManager = MockLocationManager()
        mockPlacemark = MockPlacemark()
        mockGeocoder = MockGeocoder()
        sut = LocationProvider(locationManager: mockLocationManager,
                               geocoder: mockGeocoder)
    }

    override func tearDownWithError() throws {
        sut = nil
        cancellable.removeAll()
        mockLocationManager = nil
        mockGeocoder = nil
        mockPlacemark = nil
        try super.tearDownWithError()
    }

    @discardableResult
    func givenLocation() -> CLLocation {
        sut.startLocationTracking()
        let expectedLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 100, longitude: 100),
                                          altitude: .zero,
                                          horizontalAccuracy: 5,
                                          verticalAccuracy: 5,
                                          timestamp: .now)
        mockLocationManager.mockLocation = expectedLocation
        return expectedLocation
    }

    // MARK: - Test Protocol and Delegate conformance
    func test_conformsTo_LocationServiceProtocol() {
        XCTAssertTrue((sut as AnyObject) is LocationService)
    }

    func test_conformsTo_LocationManagerDelegate() {
        XCTAssertTrue((sut as AnyObject) is CLLocationManagerDelegate)
    }

    // MARK: - Test authorization
    func test_isAuthorized_givenAuthorization_ReturnsTrue() {
        mockLocationManager.authStatus = .authorizedWhenInUse

        XCTAssertTrue(service.isAuthorized)
    }

    func test_isAuthorized_givenRestrictedAuthorization_ReturnsFalse() {
        mockLocationManager.authStatus = .restricted

        XCTAssertFalse(service.isAuthorized)
    }

    func test_isAuthorized_givenNotDetermined_RequestAuthorization() {
        mockLocationManager.authorizationRequested = false
        mockLocationManager.authStatus = .notDetermined

        XCTAssertFalse(service.isAuthorized)
        XCTAssertTrue(mockLocationManager.authorizationRequested)
    }

    // MARK: Test - Location Tracking
    func test_whenCalled_locationTrackingStarted() throws {
        service.startLocationTracking(waitFor: 0)

        let delegate = try XCTUnwrap(mockLocationManager.delegate) as? LocationProvider
        XCTAssertIdentical(delegate, sut)
        XCTAssertEqual(mockLocationManager.desiredAccuracy, kCLLocationAccuracyNearestTenMeters)
        XCTAssertTrue(mockLocationManager.isUpdating)
    }

    func test_whenCalled_locationTrackingStopped() throws {
        service.startLocationTracking(waitFor: 0)

        service.stopLocationTracking()

        XCTAssertFalse(mockLocationManager.isUpdating)
        XCTAssertNil(mockLocationManager.delegate)
    }

    func test_whenLocationManager_didFail_locationTrackingStopped() {
        service.startLocationTracking(waitFor: 0)

        mockLocationManager.failWithError()

        XCTAssertFalse(mockLocationManager.isUpdating)
        XCTAssertNil(mockLocationManager.delegate)
    }


    func test_test_whenLocationManager_didFail_errorPublished() {
        service.startLocationTracking(waitFor: 0)

        let (receivedLocation, receivedError) = waitAndObserve(
            for: sut.location,
            afterChange: mockLocationManager.failWithError
        )

        XCTAssertNotNil(receivedError)
        XCTAssertNil(receivedLocation)
    }

    func test_givenCachedLocation_locationDidNotPublished() {
        sut.startLocationTracking(waitFor: 1)
        let cachedLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 100, longitude: 100),
                                        altitude: 100,
                                        horizontalAccuracy: 5,
                                        verticalAccuracy: 5,
                                        timestamp: .now - 10)
        mockLocationManager.mockLocation = cachedLocation

        let (receivedLocation, receivedError) = waitAndObserve(
            for: sut.location,
            afterChange: mockLocationManager.sendLocation,
            waitFor: 2
        )

        XCTAssertNil(receivedError)
        XCTAssertNil(receivedLocation)
    }

    func test_givenUncertainAccuracyLocation_locationDidNotPublished() {
        sut.startLocationTracking(waitFor: 1)
        let cachedLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 100, longitude: 100),
                                        altitude: 100,
                                        horizontalAccuracy: -5,
                                        verticalAccuracy: 5,
                                        timestamp: .now )
        mockLocationManager.mockLocation = cachedLocation

        let (receivedLocation, receivedError) = waitAndObserve(
            for: sut.location,
            afterChange: mockLocationManager.sendLocation,
            waitFor: 2
        )

        XCTAssertNil(receivedError)
        XCTAssertNil(receivedLocation)
    }

    func test_givenLocation_locationPublished() {
        let expectedLocation = givenLocation()

        let (receivedLocation, receivedError) = waitAndObserve(
            for: sut.location,
            afterChange: mockLocationManager.sendLocation
        )

        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedLocation, expectedLocation)
    }

    func test_whenLocationTracked_trackingStopped() {
        givenLocation()

        mockLocationManager.sendLocation()

        XCTAssertFalse(mockLocationManager.isUpdating)
        XCTAssertNil(mockLocationManager.delegate)
    }

    // MARK: - Geocoding
    func test_geocodingRequest() {
        sut.startGeocoding(mockLocation)

        XCTAssertTrue(mockGeocoder.geocodingRequested)
    }

    func test_whenGeocodingFail_ErrorPublished() {
        mockGeocoder.shouldFail = true
        
        let exp = expectation(description: "should return error")
        var receivedPlacemark: CLPlacemark?
        var receivedError: Error?
        let token = sut.placemark
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                exp.fulfill()
            } receiveValue: { placemark in
                receivedPlacemark = placemark
            }

        sut.startGeocoding(mockLocation)

        wait(for: [exp], timeout: 1)
        token.cancel()

        XCTAssertNotNil(receivedError)
        XCTAssertNil(receivedPlacemark)
    }

    func test_givenPlacemark_placemarkPublished() throws {
        let exp = expectation(description: "should return placemark")
        var receivedPlacemark: CLPlacemark?
        var receivedError: Error?
        let token = sut.placemark
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                exp.fulfill()
            } receiveValue: { placemark in
                receivedPlacemark = placemark
            }

        sut.startGeocoding(mockLocation)

        wait(for: [exp], timeout: 1)
        token.cancel()

        receivedPlacemark = try XCTUnwrap(receivedPlacemark)
        XCTAssertNil(receivedError)
        XCTAssertEqual(mockPlacemark.name, receivedPlacemark?.name)
        XCTAssertEqual(mockPlacemark.location?.coordinate.latitude,
                       receivedPlacemark?.location?.coordinate.latitude)
        XCTAssertEqual(mockPlacemark.location?.coordinate.longitude,
                       receivedPlacemark?.location?.coordinate.longitude)
    }
}

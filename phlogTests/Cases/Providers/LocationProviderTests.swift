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
        mockLocationManager = nil
        mockGeocoder = nil
        mockPlacemark = nil
        cancellable.removeAll()
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
        service.startLocationTracking()

        let delegate = try XCTUnwrap(mockLocationManager.delegate) as? LocationProvider
        XCTAssertEqual(delegate, sut)
        XCTAssertEqual(mockLocationManager.desiredAccuracy, kCLLocationAccuracyNearestTenMeters)
        XCTAssertTrue(mockLocationManager.isUpdating)
    }

    func test_whenCalled_locationTrackingStopped() throws {
        service.startLocationTracking()

        service.stopLocationTracking()

        XCTAssertFalse(mockLocationManager.isUpdating)
        XCTAssertNil(mockLocationManager.delegate)
    }

    func test_whenLocationManager_DiDFail_locationTrackingStopped() {
        service.startLocationTracking()

        mockLocationManager.failWithError()

        XCTAssertFalse(mockLocationManager.isUpdating)
        XCTAssertNil(mockLocationManager.delegate)
    }

    func test_test_whenLocationManager_DiDFail_errorPublished() {
        service.startLocationTracking()
        let expectation = expectation(description: "error published")
        var expectedError: Error?

        sut.location
            .sink { result in
                switch result {
                case .failure(let error):
                    expectedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellable)

        mockLocationManager.failWithError()

        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(expectedError)
    }

    func test_givenLocation_locationPublished() {
        let expectation = expectation(description: "location published")
        let expectedLocation = givenLocation()

        var receivedLocation: CLLocation?
        var receivedError: Error?
        sut.location
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { location in
                receivedLocation = location
            })
            .store(in: &cancellable)

        mockLocationManager.sendLocation()

        wait(for: [expectation], timeout: 1)
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
        givenLocation()

        mockLocationManager.sendLocation()

        XCTAssertTrue(mockGeocoder.geocodingRequested)
    }

    func test_whenGeocodingFail_ErrorPublished() {
        givenLocation()
        let expectation = expectation(description: "error published")
        mockGeocoder.shouldFail = true

        var receivedError: Error?
        sut.placemark
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellable)

        mockLocationManager.sendLocation()

        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(receivedError)
    }

    func test_givenPlacemark_placemarkPublished() throws {
        givenLocation()
        let expectation = expectation(description: "placemark published")

        var receivedPlacemark: CLPlacemark?
        var receivedError: Error?
        sut.placemark
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { placemark in
                receivedPlacemark = placemark
            })
            .store(in: &cancellable)

        mockLocationManager.sendLocation()

        wait(for: [expectation], timeout: 1)
        XCTAssertNil(receivedError)
        receivedPlacemark = try XCTUnwrap(receivedPlacemark)
        XCTAssertEqual(mockPlacemark.name, receivedPlacemark?.name)
        XCTAssertEqual(mockPlacemark.location?.coordinate.latitude,
                       receivedPlacemark?.location?.coordinate.latitude)
        XCTAssertEqual(mockPlacemark.location?.coordinate.longitude,
                       receivedPlacemark?.location?.coordinate.longitude)
    }
}

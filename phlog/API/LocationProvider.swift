//
//  LocationProvider.swift
//  phlog
//
//  Created by Miroslav Taleiko on 07.05.2022.
//

import Foundation
import CoreLocation
import Combine

protocol LocationService {
    var location: PassthroughSubject<CLLocation, Error> { get }
    var isAuthorized: Bool { get }

    func startLocationTracking(waitFor timeInterval: TimeInterval)
    func stopLocationTracking()

    var placemark: PassthroughSubject<CLPlacemark, Error> { get }
    func startGeocoding(_ location: CLLocation)
}


class LocationProvider: NSObject, LocationService {
    private(set) var location = PassthroughSubject<CLLocation, Error>()
    private(set) var placemark = PassthroughSubject<CLPlacemark, Error>()

    private let locationManager: CLLocationManager
    private let geocoder: CLGeocoder

    init(locationManager: CLLocationManager, geocoder: CLGeocoder) {
        self.locationManager = locationManager
        self.geocoder = geocoder
    }

    var isAuthorized: Bool {
        let authorizationStatus = locationManager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return false
        case .restricted, .denied:
            return false
        default:
            return true
        }
    }

    func startLocationTracking(waitFor timeInterval: TimeInterval = 60) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()

        // Starting the timer
        // If we couldn't track location for some time
        // Then stop
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(timeOut),
                                     userInfo: nil,
                                     repeats: false)
    }

    func stopLocationTracking() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }

        if let timer = timer {
            timer.invalidate()
        }
    }

    private var timer: Timer?
    @objc private func timeOut() {
        stopLocationTracking()
        location.send(completion: .finished)
    }
}

// MARK: - CLLocationManager Delegate
extension LocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationTracking()
        location.send(completion: .failure(error))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let receivedLocation = locations.last!
        // Checking for cached values
        guard receivedLocation.timestamp.timeIntervalSinceNow > -5,
              receivedLocation.horizontalAccuracy > 0 else {
            return
        }

        location.send(receivedLocation)
        location.send(completion: .finished)

        stopLocationTracking()
    }
}

// MARK: - Geocoding
extension LocationProvider {
    func startGeocoding(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.placemark.send(completion: .failure(error))
                return
            }

            if let places = placemarks,
               !places.isEmpty,
               let placemark = places.last {

                self.placemark.send(placemark)
            }
            self.placemark.send(completion: .finished)
        }
    }
}

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

    func startLocationTracking()
    func stopLocationTracking()

    var placemark: PassthroughSubject<CLPlacemark, Error> { get }
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

    func startLocationTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }

    func stopLocationTracking() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
    }


}

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

        geocoder.reverseGeocodeLocation(receivedLocation) { placemarks, error in
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
        location.send(receivedLocation)
        location.send(completion: .finished)
        ////        stopLocationTracking()
        ////        addLocation(location: receivedLocation, placemark: placemark)

    }
}

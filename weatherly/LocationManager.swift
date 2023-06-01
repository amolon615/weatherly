

import SwiftUI
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject{
    private let locationManager = CLLocationManager()
    private var completion: ((Result<Location, Error>) -> Void)?
    
    struct Location {
        let latitude: Double
        let longitude: Double
    }
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func fetchCityLocation(cityName: String, completion: @escaping (Result<Location, Error>) -> Void) {
        self.completion = completion
        
        CLGeocoder().geocodeAddressString(cityName) { (placemarks, error) in
            if let error = error {
                self.completion?(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                let error = NSError(domain: "Invalid location data", code: 0, userInfo: nil)
                self.completion?(.failure(error))
                return
            }
            
            let locationData = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.completion?(.success(locationData))
        }
    }
    
    // Request location authorization
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            let error = NSError(domain: "Location permission not granted", code: 0, userInfo: nil)
            completion?(.failure(error))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        if let location = locations.last {
            let locationData = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            completion?(.success(locationData))
        } else {
            let error = NSError(domain: "Failed to retrieve location", code: 0, userInfo: nil)
            completion?(.failure(error))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        completion?(.failure(error))
    }
}


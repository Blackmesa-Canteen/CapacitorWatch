import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager

    // Expose location data to SwiftUI views
    @Published var location: CLLocationCoordinate2D?

    override init() {
        self.locationManager = CLLocationManager()
        super.init()

        // Set the delegate to this class
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Request permission to use location services
        self.locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate method to handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Update the published location data
        DispatchQueue.main.async {
            self.location = newLocation.coordinate
            print("Updated location: \(self.location?.latitude ?? 0), \(self.location?.longitude ?? 0)")
        }
    }

    // Handle location failure or permission issues
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get the location: \(error.localizedDescription)")
    }
}

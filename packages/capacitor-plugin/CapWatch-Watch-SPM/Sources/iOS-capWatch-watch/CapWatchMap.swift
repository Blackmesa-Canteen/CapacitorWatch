//
//  File.swift
//  
//
//  Created by Xiaotian Li on 15/10/2024.
//

import SwiftUI
import MapKit
import CoreLocation

// Conform CLLocationCoordinate2D to Equatable so it can work with onChange
extension CLLocationCoordinate2D: Equatable {
public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct CapWatchMap: View {

    // Bind to the location manager using @StateObject
    @StateObject private var locationManager = LocationManager()

    // State for the region of the map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), // Default coordinate until GPS signal
    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
)

    // Binding external data (such as preset coordinates)
    var coordinateString: String?  // Optional preset coordinates from the view model

        init(_ text: String, _ vm: [String: String]? = nil) {
        // Handle preset coordinates from the view model (if there's any)
        let coorString = CapWatchMap.replaceVars(text, with: vm)
        self.coordinateString = coorString

        if let parsedCoordinate = CapWatchMap.coordinateFrom(coordinate: coorString) {
            self._region = State(initialValue: MKCoordinateRegion(
                center: parsedCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        }
    }

    var body: some View {
        // Map that uses the region property tied to state
        Map(coordinateRegion: $region, annotationItems: createAnnotations()) { item in
        MapMarker(coordinate: item.coordinate, tint: .red)
        }
    .frame(height: 200)
    .onAppear {
            // Start location services
            locationManager.startUpdatingLocation()
        }
    .onDisappear {
            // Stop location services when view disappears
            locationManager.stopUpdatingLocation()
        }
    .onChange(of: locationManager.location) { location in
            // When the location updates, move the map region to the new center
            if let location = location {
                region.center = location  // Update the map's center with the new current location
            }
        }
    }

    // Create annotation item for the marker
    func createAnnotations() -> [IdentifiableCoordinate] {
        // If there's a GPS location from the location manager, place a marker at that point
        if let location = locationManager.location {
            return [IdentifiableCoordinate(coordinate: location)]
        }

        // Otherwise, use the initial preset (if any)
        if let coord = CapWatchMap.coordinateFrom(coordinate: coordinateString ?? "") {
            return [IdentifiableCoordinate(coordinate: coord)]
        }

        return []
    }

    // MARK: - Helper Methods
static func coordinateFrom(coordinate: String) -> CLLocationCoordinate2D? {
        let coordinates = coordinate.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
    if coordinates.count == 2 {
        return CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])
    } else {
        return nil  // Return nil if the input is invalid
    }
}

static func replaceVars(_ text: String, with vm: [String: String]?) -> String {
        if let vm = vm {
            if text.hasPrefix("$"), let varValue = vm[String(text.dropFirst())] {
                return varValue
            }
        }
        return text
    }
}

// A simple wrapper for CLLocationCoordinate2D to make it Identifiable
struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

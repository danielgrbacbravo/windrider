//
//  Route.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 01/03/2024.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

struct Route {
    let routeId: UUID?
    let points: [CLLocationCoordinate2D]
    var wind: Wind?
    
    init(routeId: String? = nil, points: [CLLocationCoordinate2D]) {
        self.routeId = UUID()
        self.points = points
    }
    
    func calcuateCenterCoordinate() -> CLLocationCoordinate2D {
        var maxLat: CLLocationDegrees = -90
        var maxLon: CLLocationDegrees = -180
        var minLat: CLLocationDegrees = 90
        var minLon: CLLocationDegrees = 180
        
        for coordinate in points {
            let lat = Double(coordinate.latitude)
            let long = Double(coordinate.longitude)
            
            maxLat = max(maxLat, lat)
            maxLon = max(maxLon, long)
            minLat = min(minLat, lat)
            minLon = min(minLon, long)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        return center
    }
    
    
    
        
    
    
    // Helper struct to decode/encode CLLocationCoordinate2D since it's not directly Codable
    private struct Point: Codable {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }
}

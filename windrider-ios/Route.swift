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

struct Route: Codable {
    let routeId: String?
    let points: [CLLocationCoordinate2D]
    
    
    init(routeId: String? = nil, points: [CLLocationCoordinate2D]) {
        self.routeId = routeId
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
    
    
    // CodingKeys enum to map the properties to the JSON keys
    // everything below is for Codable conformance

    enum CodingKeys: String, CodingKey {
        case routeId
        case points
    }

    // Custom initializer from Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decodeIfPresent(String.self, forKey: .routeId)
        
        var pointsArrayForInit = [CLLocationCoordinate2D]()
        var pointsContainer = try container.nestedUnkeyedContainer(forKey: .points)
        while !pointsContainer.isAtEnd {
            let point = try pointsContainer.decode(Point.self)
            let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            pointsArrayForInit.append(coordinate)
        }
        points = pointsArrayForInit
    }

    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(routeId, forKey: .routeId)
        
        var pointsContainer = container.nestedUnkeyedContainer(forKey: .points)
        for point in points {
            let pointToEncode = Point(latitude: point.latitude, longitude: point.longitude)
            try pointsContainer.encode(pointToEncode)
        }
        
    }
    
    // Helper struct to decode/encode CLLocationCoordinate2D since it's not directly Codable
    private struct Point: Codable {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }
}

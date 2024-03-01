//
//  Route.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 01/03/2024.
//

import Foundation

struct Route: Codable {
    let routeId: String?
    let points: [RoutePoint]
    
    init(points: [RoutePoint]) {
        self.routeId = nil
        self.points = points
    }
    
    // finds the bounding box of the route
    // returns the two points that define the bounding box
    public func caluateBoundingBox(route: Route) -> [RoutePoint]{
        var minLat: Double = 90
        var maxLat: Double = -90
        var minLon: Double = 180
        var maxLon: Double = -180
        for point in route.points {
            if point.latitude < minLat {
                minLat = point.latitude
            }
            if point.latitude > maxLat {
                maxLat = point.latitude
            }
            if point.longitude < minLon {
                minLon = point.longitude
            }
            if point.longitude > maxLon {
                maxLon = point.longitude
            }
        }
        return [RoutePoint(latitude: minLat, longitude: minLon, direction: 0, timestamp: Date()), RoutePoint(latitude: maxLat, longitude: maxLon, direction: 0, timestamp: Date())]
    }
    
    
}



struct RoutePoint: Codable {
    let latitude: Double
    let longitude: Double
    let direction: Double
    let timestamp: Date

    init(latitude: Double, longitude: Double, direction: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.direction = direction
        self.timestamp = timestamp
    }
}


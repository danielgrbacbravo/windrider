//
//  RouteWeatherCondition.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 02/03/2024.
//

import Foundation
import CoreLocation

class RouteWeatherCondition {
    
    public func calculateCoordinateDirection(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Double {
        let lat1 = start.latitude
        let lon1 = start.longitude
        let lat2 = end.latitude
        let lon2 = end.longitude
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let brng = atan2(y, x)
        
        return brng
    }
    
    public func calculateAllCoordinateDirections(coordinates: [CLLocationCoordinate2D]) -> [Double] {
        var directions: [Double] = []
        for i in 0..<coordinates.count - 1 {
            let start = coordinates[i]
            let end = coordinates[i + 1]
            let direction = calculateCoordinateDirection(start: start, end: end)
            directions.append(direction)
            
            // TODO: add the last direction becaause we go to coordinates.count - 1
        }
        return directions
    }
    
    public func calculateRelativeWindDirection(windDirection: Double, routeDirection: Double) -> Double {
        let relativeDirection = windDirection - routeDirection
        return relativeDirection
    }
    
    
    public func calculateAllRelativeWindDirections(windDirection: Double, routeDirections: [Double]) -> [Double] {
        var relativeDirections: [Double] = []
        for direction in routeDirections {
            let relativeDirection = calculateRelativeWindDirection(windDirection: windDirection, routeDirection: direction)
            relativeDirections.append(relativeDirection)
        }
        return relativeDirections
    }
    
    public func calculateWindCondition(relativeWindDirection: Double) -> String {
        if relativeWindDirection < 0 {
            return "Headwind"
        } else if relativeWindDirection > 0 {
            return "Tailwind"
        } else {
            return "Crosswind"
        }
    }
    
    
    
}


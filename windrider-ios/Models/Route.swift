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

extension CLLocationDegrees {
    func toRadians() -> Double {
        return self * Double.pi / 180
    }
}

extension CLLocationDegrees {
    func toDegrees() -> Double {
        return self * 180 / Double.pi
    }
}

struct Route {
    let routeId: UUID?
    var name: String?
    var averageCoordinate: CLLocationCoordinate2D
    var coordinates: [CLLocationCoordinate2D]?
    var coordinateAngles: [Double]?
    var coordinateWindData: [CoordinateWindData]?
    
    // init
    init(name: String, coordinates: [CLLocationCoordinate2D]){
        self.routeId = UUID()
        self.name = name
        
        let averageCoordinate = Route.calculateAverageCoordinate(coordinates: coordinates)
        self.averageCoordinate = averageCoordinate
        self.coordinates = coordinates
        self.coordinateWindData = nil
        
        let coordinateAngles = Route.calulcateCoordinateAngles(coordinates: coordinates)
        self.coordinateAngles = coordinateAngles
    }
    
    
    mutating public func setWindData(windData: [CoordinateWindData]){
        self.coordinateWindData = windData
    }
    

    static private func calculateAngle(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Double {
        let startLat = start.latitude.toRadians()
        let startLon = start.longitude.toRadians()
        let endLat = end.latitude.toRadians()
        let endLon = end.longitude.toRadians()
        
        let dLon = endLon - startLon
        
        let y = sin(dLon) * cos(endLat)
        let x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLon)
        
        let angle = atan2(y, x)
        
        return angle.toDegrees()
    }
    
    static private func calulcateCoordinateAngles(coordinates: [CLLocationCoordinate2D]) -> [Double] {
        var angles: [Double] = []
        
        for i in 0..<coordinates.count - 1 {
            let start = coordinates[i]
            let end = coordinates[i + 1]
            let angle = Route.calculateAngle(start: start, end: end)
            angles.append(angle)
        }
        
        return angles
    }
    
    
    static private func calculateAverageCoordinate(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        var avgLat: Double = 0
        var avgLon: Double = 0
        
        // Ensure there are coordinates to avoid division by zero
        guard !coordinates.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        for coordinate in coordinates {
            avgLat += coordinate.latitude
            avgLon += coordinate.longitude
        }
        
        avgLat /= Double(coordinates.count)
        avgLon /= Double(coordinates.count)
        
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
    }
    
    static private func calculateCoordinateAngles(coordinates: [CLLocationCoordinate2D]) -> [Double] {
        var angles: [Double] = []
        
        for i in 0..<coordinates.count - 1 {
            let start = coordinates[i]
            let end = coordinates[i + 1]
            let angle = Route.calculateAngle(start: start, end: end)
            angles.append(angle)
        }
        
        return angles
    }
}
        
struct CoordinateWindData: Hashable {
    var windSpeed: Double
    var windDirection: Double
    var relativeWindDirection: Double
    var headwindPercentage: Double
    var tailwindPercentage: Double
    var crosswindPercentage: Double

    init(windSpeed: Double, windDirection: Double, coordinateAngle: Double) {
        // Directly initialize properties without calling instance methods
        self.windSpeed = windSpeed
        self.windDirection = windDirection

        // Calculate the relative direction directly in the initializer
        let relativeDirection = CoordinateWindData.calculateRelativeDirection(windDirection: windDirection, angle: coordinateAngle)
        self.relativeWindDirection = relativeDirection

        // Calculate wind percentages directly in the initializer
        self.headwindPercentage = CoordinateWindData.calculateHeadwindPercentage(relativeDirection: relativeDirection)
        self.tailwindPercentage = CoordinateWindData.calcluateTailwindPercentage(relativeDirection: relativeDirection)
        self.crosswindPercentage = CoordinateWindData.calculateCrosswindPercentage(relativeDirection: relativeDirection)
    }

    // Use static methods for calculations to avoid 'self' usage issues
    static private func calculateRelativeDirection(windDirection: Double, angle: Double) -> Double {
        let relativeDirection = windDirection - angle
        return relativeDirection < 0 ? 360 + relativeDirection : relativeDirection
    }

    static private func calculateHeadwindPercentage(relativeDirection: Double) -> Double {
        return (relativeDirection > 315 || relativeDirection < 45) ? 100 : 0
    }

    static private func calcluateTailwindPercentage(relativeDirection: Double) -> Double {
        return (relativeDirection > 135 && relativeDirection < 225) ? 100 : 0
    }

    static private func calculateCrosswindPercentage(relativeDirection: Double) -> Double {
        if (relativeDirection > 45 && relativeDirection < 135) || (relativeDirection > 225 && relativeDirection < 315) {
            return 100
        }
        return 0
    }
}

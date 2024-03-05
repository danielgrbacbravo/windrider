//
//  BikeRoute.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import Foundation
import SwiftData
import WidgetKit
import CoreLocation
import SwiftUI

@Model
class BikeRoute{
    // general route information
    @Attribute(.unique) let bikeRouteId: UUID?
    @Attribute(.unique) var name: String?
    // path information
    var averageCoordinate: Coordinate
    var coordinates: [Coordinate]?
    var coordinateAngles: [Int]?
    // associated wind data
    var bikeRouteCondition = BikeRouteCondition()
    var bikeRouteCoordinateCondition = [BikeRouteCoordinateCondition]()
 
    
    // init
    init(name: String? = nil, averageCoordinate: Coordinate, coordinates: [Coordinate]? = nil, coordinateAngles: [Int]? = nil, bikeRouteCondition: BikeRouteCondition? = nil, bikeRouteCoordinateCondition: [BikeRouteCoordinateCondition]? = nil) {
        self.bikeRouteId = UUID()
        self.name = name
        self.averageCoordinate =  BikeRoute.calculateAverageCoordinate(coordinates: coordinates!)
        self.coordinates = coordinates
        // computed properties
        self.coordinateAngles = BikeRoute.findAllNorthRelativeAngles(from: coordinates!)
    }
    // functions to compute coordinateAngles
    static private func findNorthRelativeAngle(from start: Coordinate, to end: Coordinate) -> Int {
        var angleDegrees: Double = 0
        let startLat: Double = start.latitude
        let startLong: Double = start.longitude
        let endLat: Double = end.latitude
        let endLong: Double = end.longitude
        
        // Calculate deltas between two coordinates
        let deltaLat: Double = endLat - startLat
        let deltaLong: Double = endLong - startLong
        
        // Calculate angle using atan2 for delta longitude and latitude
        angleDegrees = atan2(deltaLong, deltaLat)
        
        // Convert radians to degrees
        angleDegrees = angleDegrees * (180 / .pi)
        
        // Normalize the angle to a 0 to 360 degrees range
        if angleDegrees < 0 {
            angleDegrees += 360
        }

        return Int(angleDegrees)
    }
    
    static private func findAllNorthRelativeAngles(from coordinates: [Coordinate]) -> [Int] {
        var angles: [Int] = []
        for i in 0..<coordinates.count-1 {
            let angle = BikeRoute.findNorthRelativeAngle(from: coordinates[i], to: coordinates[i+1])
            angles.append(angle)
        }
        return angles
    }
    // functions to compute averageCoordinate
    static private func calculateAverageCoordinate(coordinates: [Coordinate]) -> Coordinate {
        var averageLat: Double = 0
        var averageLong: Double = 0
        for coordinate in coordinates {
            averageLat += coordinate.latitude
            averageLong += coordinate.longitude
        }
        averageLat = averageLat / Double(coordinates.count)
        averageLong = averageLong / Double(coordinates.count)
        return Coordinate(latitude: averageLat, longitude: averageLong)
    }
    
    
    public func fetchAndPopulateBikeRouteConditions(openWeatherMapAPI: OpenWeatherMapAPI) async throws {
        do{
            let response =  try await openWeatherMapAPI.fetchWeatherConditionAtCoordinate( coordinate: self.averageCoordinate)
            let currentWindSpeed = response.wind.speed
            let currentWindAngle = response.wind.deg
            // create and append the array  of BikeRouteCoordinateCondition objects
            var bikeRouteCoordinateConditionArray: [BikeRouteCoordinateCondition] = []
            if let coordinateAngles = self.coordinateAngles{
                for(index, _) in coordinateAngles.enumerated() {
                    let currentCoordinateCondition = BikeRouteCoordinateCondition(coordinateAngle: self.coordinateAngles![index], windSpeed: currentWindSpeed, windAngle: currentWindAngle )
                    bikeRouteCoordinateConditionArray.append(currentCoordinateCondition)

                }
            }
            self.bikeRouteCoordinateCondition = bikeRouteCoordinateConditionArray
        } catch{
            
        }
    }
  
}

struct BikeRouteConditionEntry: TimelineEntry {
    let date: Date
    var bikeRoute: BikeRoute
    var headwindColor: Color?
    var crosswindColor: Color?
    var tailwindColor: Color?
    var windSpeedColor: Color?
    
    init(date: Date, bikeRoute: BikeRoute){
        self.date = date
        self.bikeRoute = bikeRoute
    }
    
    
}


// precondition: bikeRouteCoordinateCondition is not empty
@Model
class BikeRouteCondition{
    var windSpeed: Int
    var totalHeadwindPercentage: Int
    var totalCrosswindPercentage: Int
    var totalTailwindPercentage: Int
    
    init(windSpeed: Int = 0, totalHeadwindPercentage: Int = 0, totalCrosswindPercentage: Int = 0, totalTailwindPercentage: Int = 0) {
        self.windSpeed = windSpeed
        self.totalHeadwindPercentage = totalHeadwindPercentage
        self.totalCrosswindPercentage = totalCrosswindPercentage
        self.totalTailwindPercentage = totalTailwindPercentage
    }
    
    init(windSpeed: Int, bikeRouteCoordinateCondition: [BikeRouteCoordinateCondition]) {
        self.windSpeed = windSpeed
        self.totalHeadwindPercentage = BikeRouteCondition.findTotalHeadwindPercentage(bikeRouteCoordinateCondition: bikeRouteCoordinateCondition)
        self.totalCrosswindPercentage = BikeRouteCondition.findTotalCrosswindPercentage(bikeRouteCoordinateCondition: bikeRouteCoordinateCondition)
        self.totalTailwindPercentage = BikeRouteCondition.findTotalTailwindPercentage(bikeRouteCoordinateCondition: bikeRouteCoordinateCondition)
    }
    
    static func findTotalHeadwindPercentage(bikeRouteCoordinateCondition: [BikeRouteCoordinateCondition]) -> Int {
        var totalHeadwindPercentage: Int = 0
        for condition in bikeRouteCoordinateCondition {
            totalHeadwindPercentage += condition.headWindPercentage
        }
        return totalHeadwindPercentage/bikeRouteCoordinateCondition.count
    }
    
    static func findTotalCrosswindPercentage(bikeRouteCoordinateCondition: [BikeRouteCoordinateCondition]) -> Int {
        var totalCrosswindPercentage: Int = 0
        for condition in bikeRouteCoordinateCondition {
            totalCrosswindPercentage += condition.crossWindPercentage
        }
        return totalCrosswindPercentage/bikeRouteCoordinateCondition.count
    }
    
    static func findTotalTailwindPercentage(bikeRouteCoordinateCondition: [BikeRouteCoordinateCondition]) -> Int {
        var totalTailwindPercentage: Int = 0
        for condition in bikeRouteCoordinateCondition {
            totalTailwindPercentage += condition.tailWindPercentage
        }
        return totalTailwindPercentage/bikeRouteCoordinateCondition.count
    }
    
    
    
}
//precondition: windAngle is not empty
@Model
class BikeRouteCoordinateCondition{
    
    // general wind data for a coordinatef
    var relativeWindAngle: Int
    var windSpeed: Double
    // computed wind data for a coordinate
    var headWindPercentage: Int
    var tailWindPercentage: Int
    var crossWindPercentage: Int
    
    init(coordinateAngle: Int, windSpeed: Double, windAngle: Int) {
        
        let relativeWindAngle = BikeRouteCoordinateCondition.findRelativeWindAngle(coordinateAngle: coordinateAngle, windAngle: windAngle)
        self.relativeWindAngle = relativeWindAngle
        self.windSpeed = windSpeed
        self.headWindPercentage = BikeRouteCoordinateCondition.findHeadwindPercentage(relativeWindAngle: relativeWindAngle)
        self.crossWindPercentage = BikeRouteCoordinateCondition.findCrosswindPercentage(relativeWindAngle: relativeWindAngle)
        self.tailWindPercentage = BikeRouteCoordinateCondition.findTailwindPercentage(relativeWindAngle: relativeWindAngle)
    }
    
    static private func findRelativeWindAngle(coordinateAngle: Int, windAngle: Int) -> Int {
        var relativeWindAngle: Int = windAngle - coordinateAngle
        // if the result is negative, add 360 to bring it within the 0 to 360 range
        if relativeWindAngle < 0 {
            relativeWindAngle += 360
        }
        // Ensure the result is within the 0 to 360 range
        relativeWindAngle %= 360
        return relativeWindAngle
    }
    
    static private func findHeadwindPercentage(relativeWindAngle: Int) -> Int {
        if((relativeWindAngle > 260) || (relativeWindAngle > 0 && relativeWindAngle < 90)){
            let thetaRad = Double(relativeWindAngle) * Double.pi / 180
            return Int ((1 + cos(thetaRad)) / 2 * 100)
        }
        return 0
    }
    
    static private func findCrosswindPercentage(relativeWindAngle: Int) -> Int{
        let thetaRad = Double(relativeWindAngle) * Double.pi / 180
        return Int((1 - cos(2 * thetaRad)) / 2 * 100)
    }
    
    static private func findTailwindPercentage(relativeWindAngle: Int) -> Int {
        if((relativeWindAngle > 90) && (relativeWindAngle < 260)){
            let thetaRad = Double(relativeWindAngle) * Double.pi / 180
            return Int ((1 + cos(thetaRad)) / 2 * 100)
        }
        return 0
    }
    
}

@Model
class Coordinate{
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double = 0, longitude: Double = 0){
        self.latitude = latitude
        self.longitude = longitude
    }
}

//
//  CyclingPath.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class CyclingPath{
    //MARK: - Properties
    //general Cycling Path Attributes
    @Attribute(.unique) public var id: UUID?
    @Attribute(.unique) public var name: String
    public let createdAt: Date = Date()
    
    //Cycling Path Location data
    public var averageCoordinate: Coordinate?
    
    /// the coordinates are stored as an array of `Coordinate` objects
    /// because the `CLLocationCoordinate2D` struct is not .
    public var coordinates: [Coordinate] = []
    public var coordinateAngles: [Int] = []
    
    //MARK: - Initializers
    init(name: String, coordinates: [Coordinate]? = nil){
        self.name = name
        
        if let coordinates = coordinates{
            self.coordinates = coordinates
            self.averageCoordinate = CyclingPath.calculateAverageCoordinate(coordinates: coordinates)
        }
        
        self.coordinateAngles = CyclingPath.findNorthRelativeAngles(coordinates: coordinates ?? [])
    }
    
    //MARK: Getters/Setters
    
    
    /// Sets the coordinates of the cycling path.
    ///
    /// This function sets the coordinates of the cycling path. It also calculates the average coordinate of the input coordinates.
    /// - Parameter coordinates: An array of `CLLocationCoordinate2D` objects representing the coordinates of the cycling path.
    /// - Returns: Void
    public func setCoordinates(coordinates: [CLLocationCoordinate2D]){
            var tempCoordinates: [Coordinate] = []
            for coordinate in coordinates{
                tempCoordinates.append(Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
            }
        self.coordinates = tempCoordinates
    }
    
    
    
    /// Gets the coordinates of the cycling path.
    ///
    /// This function returns the coordinates of the cycling path as an array of `CLLocationCoordinate2D` objects.
    /// - Returns: An array of `CLLocationCoordinate2D` objects representing the coordinates of the cycling path.
    public func getCoordinates() -> [CLLocationCoordinate2D]{
        var tempCoordinates: [CLLocationCoordinate2D] = []
        for coordinate in coordinates{
            tempCoordinates.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        return tempCoordinates
    }
    
    
    /// gets the average coordinate of the cycling path.
    ///
    /// This function returns the average coordinate of the cycling path as a `CLLocationCoordinate2D` object.
    public func getAverageCoordinate() -> CLLocationCoordinate2D?{
        guard let averageCoordinate = averageCoordinate else{
            return nil
        }
        return CLLocationCoordinate2D(latitude: averageCoordinate.latitude, longitude: averageCoordinate.longitude)
    }
    
    //MARK: - Initializer methods
    
    /// Calculates the average coordinate from an array of coordinates.
    ///
    /// This function computes the average latitude and longitude values from an array of `Coordinate` objects. If the array is nil or empty, the function returns nil, indicating that an average coordinate cannot be calculated.
    ///
    /// - Parameter coordinates: An optional array of `Coordinate` objects to be averaged. If the array is nil or empty, the function returns nil.
    ///
    /// - Returns: An optional `Coordinate` object representing the average latitude and longitude of the input coordinates. Returns nil if the input array is nil or empty.
    static private func calculateAverageCoordinate(coordinates: [Coordinate]? ) -> Coordinate? {
        guard let coordinates = coordinates, !coordinates.isEmpty else {
            return nil
        }

        var sumLatitude: Double = 0
        var sumLongitude: Double = 0
        for coordinate in coordinates {
            sumLatitude += coordinate.latitude
            sumLongitude += coordinate.longitude
        }
        
        let averageLatitude = sumLatitude / Double(coordinates.count)
        let averageLongitude = sumLongitude / Double(coordinates.count)
        
        return Coordinate(latitude: averageLatitude, longitude: averageLongitude)
    }
    
    

    
    /// Calculates the angles between two coordinates in degrees. relative to north. (ie 0 degrees is north, 90 degrees is east, 180 degrees is south, 270 degrees is west)
    ///
    /// This function computes the angle between two coordinates in degrees, relative to north. The angle is calculated using the `atan2` function, which returns the angle in radians. This value is then converted to degrees and normalized to the range 0 to 360 degrees.
    /// - Parameter start: A `Coordinate` object representing the starting point of the angle calculation.
    /// - Parameter end: A `Coordinate` object representing the ending point of the angle calculation.
    static public func findNorthRelativeAngle(from start: Coordinate, to end: Coordinate) -> Int {
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
    
    /// Finds the north relative angles between the coordinates of the cycling path.
    /// This function calculates the angles between the coordinates of the cycling path and stores them in the `coordinateAngles` array. The angles are relative to north, with 0 degrees being north, 90 degrees being east, 180 degrees being south, and 270 degrees being west.
    /// - Returns: Void
    /// - Postcondition: The `coordinateAngles` array is populated with the north relative angles between the coordinates of the cycling path.
    static public func findNorthRelativeAngles(coordinates: [Coordinate]) -> [Int] {
        
        var tempAngles: [Int] = []
        for i in 0..<coordinates.count-1{
            let angle = CyclingPath.findNorthRelativeAngle(from: coordinates[i], to: coordinates[i+1])
            tempAngles.append(angle)
        }
        return tempAngles
    }
}

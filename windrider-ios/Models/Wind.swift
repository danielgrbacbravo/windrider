//
//  Wind.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 01/03/2024.
//

import Foundation


struct Wind: Codable{
    var speed: Double // m/s
    var direction: Double // degrees
    var relativeDirection: Double
    var gust: Double // m/s
    var lastUpdated: time_t
    var location: String
    
    init(speed: Double, direction: Double, relativeDirection: Double, gust: Double, lastUpdated: time_t, location: String){
        self.speed = speed
        self.direction = direction
        self.relativeDirection = relativeDirection
        self.gust = gust
        self.lastUpdated = lastUpdated
        self.location = location
    }
    // very basic wind direction calculation (probably not accurate)
    func calculateRelativeDirection(bikeHeading: Double, windHeading: Double ) -> Double {
        let relativeDirection = windHeading - bikeHeading
        return relativeDirection
    }
}

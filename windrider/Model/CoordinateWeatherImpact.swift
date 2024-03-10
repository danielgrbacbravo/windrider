//
//  CoordinateWeatherImpact.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation

/// Represents the wind impact on a specific coordinate with optional properties for wind direction and impact percentages.
struct CoordinateWeatherImpact {
    /// Wind direction in degrees relative to the coordinate (0 for north, 90 for east, etc.). `nil` if unknown.
    var relativeWindDirectionInDegrees: Double?
    
    /// Percentage of wind acting as a headwind, slowing movement. `nil` if unknown.
    var headwindPercentage: Double?
    
    /// Percentage of wind acting as a tailwind, speeding up movement. `nil` if unknown.
    var tailwindPercentage: Double?
    
    /// Percentage of wind acting as a crosswind, affecting lateral movement. `nil` if unknown.
    var crosswindPercentage: Double?

    /// Initializes the struct with wind direction and impact percentages. All parameters are optional.
    init(relativeWindDirectionInDegrees: Double?, headwindPercentage: Double?, tailwindPercentage: Double?, crosswindPercentage: Double?){
        self.relativeWindDirectionInDegrees = relativeWindDirectionInDegrees
        self.headwindPercentage = headwindPercentage
        self.tailwindPercentage = tailwindPercentage
        self.crosswindPercentage = crosswindPercentage
    }
}


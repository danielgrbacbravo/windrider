//
//  WeatherOverviewForCoordinate.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation

struct WeatherOverviewForCoordinate{
    var relativeWindDirectionInDegrees: Double?
    var headwindPercentage: Double?
    var tailwindPercentage: Double?
    var crosswindPercentage: Double?

    init(relativeWindDirectionInDegrees: Double?, headwindPercentage: Double?, tailwindPercentage: Double?, crosswindPercentage: Double?){
        self.relativeWindDirectionInDegrees = relativeWindDirectionInDegrees
        self.headwindPercentage = headwindPercentage
        self.tailwindPercentage = tailwindPercentage
        self.crosswindPercentage = crosswindPercentage
    }
}

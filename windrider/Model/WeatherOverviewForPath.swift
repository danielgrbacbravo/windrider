//
//  WeatherOverviewForPath.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation

struct WeatherOverviewForPath{
    var temperature: Double
    var windSpeed: Double
    var headwindPercentage: Double?
    var tailwindPercentage: Double?
    var crosswindPercentage: Double?
    
    init(temperature: Double, windSpeed: Double){
        self.temperature = temperature
        self.windSpeed = windSpeed
        
    }
    
    init(temperature: Double, windSpeed: Double, headwindPercentage: Double, tailwindPercentage: Double, crosswindPercentage: Double){
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.headwindPercentage = headwindPercentage
        self.tailwindPercentage = tailwindPercentage
        self.crosswindPercentage = crosswindPercentage
    }
}

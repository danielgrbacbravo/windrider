//
//  Configuration.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 20/03/2024.
//

import Foundation
import SwiftData


@Model
class Configuration{
	var openWeatherMapAPIKey: String?
	var upperTemperature: Double
	var idealTemperature: Double
	var upperWindSpeed: Double
	var headwindWeight: Double
	var tailwindWeight: Double
	var crosswindWeight: Double
	
	init(openWeatherMapAPIKey: String,
		 upperTemperature: Double = 40.7,
		 idealTemperature: Double = 23.0,
		 upperWindSpeed: Double = 20,
		 headwindWeight: Double = 2,
		 crosswindWeight: Double = 1,
		 tailwindWeight: Double = 1
	){
		self.openWeatherMapAPIKey = openWeatherMapAPIKey
		self.upperTemperature = upperTemperature
		self.idealTemperature = idealTemperature
		self.upperWindSpeed = upperWindSpeed
		self.headwindWeight = headwindWeight
		self.crosswindWeight = crosswindWeight
		self.tailwindWeight = tailwindWeight
	}
}

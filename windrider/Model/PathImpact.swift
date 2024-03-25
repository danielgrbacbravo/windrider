//
//  PathImpact.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 22/03/2024.
//

import Foundation
/// this stuct represents the overall condition of a path based on the headwind, crosswind, and tailwind values.
struct PathImpact{
	let headwindPercentage: Int
	let crosswindPercentage: Int
	let tailwindPercentage: Int
	
	var windSpeed: Float
	var temperature: Float
	
	var cyclingScore: Int
	var cyclingMessage: String
	
	init(headwindPercentage: Int, crosswindPercentage: Int, tailwindPercentage: Int) {
		self.headwindPercentage = headwindPercentage
		self.crosswindPercentage = crosswindPercentage
		self.tailwindPercentage = tailwindPercentage
		self.windSpeed = 0
		self.temperature = 0
		self.cyclingScore = 0
		self.cyclingMessage = ""
	}
  
  init(){
    self.headwindPercentage = 0
    self.crosswindPercentage = 0
    self.tailwindPercentage = 0
    self.windSpeed = 0
    self.temperature = 0
    self.cyclingScore = 0
    self.cyclingMessage = ""
  }
	
}

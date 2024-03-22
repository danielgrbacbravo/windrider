//
//  CoordinateImpact.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 22/03/2024.
//

import Foundation

struct CoordinateImpact{
	
	let headwind: Float
	let crosswind: Float
	let tailwind: Float
	
	init(headwind: Float, crosswind: Float, tailwind: Float) {
		self.headwind = headwind
		self.crosswind = crosswind
		self.tailwind = tailwind
	}
	
}

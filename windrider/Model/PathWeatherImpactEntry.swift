//
//  PathWeatherImpactEntry.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 17/03/2024.
//

import Foundation
import WidgetKit
import SwiftUI
struct PathWeatherImpactEntry: TimelineEntry{
	/// The date of the entry.
	let date: Date
	/// The cycling data for the entry.
	let cyclingScore: Double
	let message: String
	let temperature: Double
	let windSpeed: Double
	let headwindPercentage: Double
	let tailwindPercentage: Double
	let crosswindPercentage: Double
	/// color computed property
	let cyclingScoreColor: Color
	/// data fetch status
	let successfullyFetched: Bool
}

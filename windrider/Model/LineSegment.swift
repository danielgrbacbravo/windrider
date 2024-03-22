//
//  LineSegment.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 22/03/2024.
//

import Foundation
import CoreLocation
import SwiftUI

/// `LineSegment` is a struct that represents a line segment on a map.
/// 
///  It consists of an array of coordinates and a color. Each line segment is defined by an array of `CLLocationCoordinate2D` objects.
///  The color of the line segment is represented by a `Color` object.
struct LineSegment	{
	var coordinateArray: [CLLocationCoordinate2D]
	var color: Color
	
	/// Initializes a new `LineSegment` object with the specified array of coordinates and color.
	/// - Parameters:
	///   - CoordinateArray: the array of `CLLocationCoordinate2D` objects that define the line segment.
	///   - Color:  the color of the line segment.
	/// - Returns: A new `LineSegment` object.
	///
	/// ## Here is an example of how to use this initializer:
	///   ```swift
	///   let lineSegment = LineSegment([
	///   CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
	///   CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)],
	///   Color: Color.red)
	///   ```
	///
	init(_ coordinateArray: [CLLocationCoordinate2D], color: Color) {
		self.coordinateArray = coordinateArray
		self.color = color
	}
	
	///  Initializes a new `LineSegment` object with the specified array of coordinates and a blue color.
	/// - Parameter coordinateArray: the array of `CLLocationCoordinate2D` objects that define the line segment.
	init(_ coordinateArray: [CLLocationCoordinate2D]) {
		self.coordinateArray = coordinateArray
		self.color = Color.blue
	}
	
	/// Initializes a new `LineSegment` object with an empty array of coordinates and a blue color.
	init() {
		self.coordinateArray = []
		self.color = Color.blue
	}
}

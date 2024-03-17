//
//  GPXParser.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 17/03/2024.
//

import Foundation
import CoreLocation
class GPXParser: NSObject, XMLParserDelegate {

var coordinates: [Coordinate] = []
var name: String = ""
	
var currentElement: String = ""
var latitude: Double = 0
var longitude: Double = 0

func parseGPX(_ data: Data) -> [Coordinate] {
	let parser = XMLParser(data: data)
	parser.delegate = self
	parser.parse()
	
	
	
	return coordinates
}
	
	func parseGPXtoCyclePath(_ data: Data, url: URL) -> CyclingPath {
	let parser = XMLParser(data: data)
	parser.delegate = self
	parser.parse()
	
	var convertedCoordinates: [CLLocationCoordinate2D] = []
	for coordinate in coordinates {
		let currentElement = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
		convertedCoordinates.append(currentElement)
	}
	if name == "" {
		name = url.lastPathComponent
	}
	return CyclingPath(name: name, coordinates: convertedCoordinates)
}

// XMLParser Delegate Methods
	
/// Called when the parser finds a new element in the XML
func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
	currentElement = elementName
	/// If the element is a trackpoint or waypoint or route point, get the latitude and longitude
	if elementName == "trkpt" {
		latitude = Double(attributeDict["lat"]!)!
		longitude = Double(attributeDict["lon"]!)!
	}
	
	if elementName == "wpt" {
		latitude = Double(attributeDict["lat"]!)!
		longitude = Double(attributeDict["lon"]!)!
	}
	
	if elementName ==  "rtept" {
		latitude = Double(attributeDict["lat"]!)!
		longitude = Double(attributeDict["lon"]!)!
	}
	//TODO: add name parsing

}
/// Called when the parser finds characters in the XML
func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
	if elementName == "trkpt"{
		let newCoordinate = Coordinate(latitude: latitude, longitude: longitude)
		coordinates.append(newCoordinate)
	}
	
	if elementName == "wpt" {
		let newCoordinate = Coordinate(latitude: latitude, longitude: longitude)
		coordinates.append(newCoordinate)
	}
	
	if elementName == "rtept" {
		let newCoordinate = Coordinate(latitude: latitude, longitude: longitude)
		coordinates.append(newCoordinate)
	}
}
}


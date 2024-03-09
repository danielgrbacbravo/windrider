//
//  CyclingPathTests.swift
//  windriderTests
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import XCTest
import CoreLocation
@testable import windrider

final class CyclingPathTests: XCTestCase {
//MARK: Average Coordinate Tests
    
    func testSameCoordinatesAverageCoordinates() {
        // Given
        let coordinates = [Coordinate(latitude: 45.0, longitude: 45.0), Coordinate(latitude: 45.0, longitude: 45.0)]
        // When
        let path = CyclingPath(name: "Test Path",coordinates: coordinates)
        
        // Then
        XCTAssertEqual(path.averageCoordinate!.latitude, 45.0)
    }
    
    func testNominalAverageCoordinates() {
        // Given
        let coordinates = [Coordinate(latitude: 45.0, longitude: 45.0), Coordinate(latitude: 46.0, longitude: 46.0)]
        // When
        let path = CyclingPath(name: "Test Path",coordinates: coordinates)
        
        // Then
        XCTAssertEqual(path.averageCoordinate!.latitude, 45.5)
    }
    
    func testNilAverageCoordinates() {
        // Given
        let coordinates = [Coordinate]()
        // When
        let path = CyclingPath(name: "Test Path",coordinates: coordinates)
        
        // Then
        XCTAssertNil(path.averageCoordinate)
    }
    
    func testEmptyAverageCoordinates() {
        // Given
        let coordinates: [Coordinate] = []
        // When
        let path = CyclingPath(name: "Test Path",coordinates: coordinates)
        
        // Then
        XCTAssertNil(path.averageCoordinate)
    }
    
    //MARK: Set/Get Coordinates Tests
    
    func testSetCoordinates() {
        // Given
        let CLLocationCoordinate2DArray = [CLLocationCoordinate2D(latitude: 45.0, longitude: 45.0), CLLocationCoordinate2D(latitude: 46.0, longitude: 46.0)]
        
        let expectedCoordinates = [Coordinate(latitude: 45.0, longitude: 45.0), Coordinate(latitude: 46.0, longitude: 46.0)]
        
        // When
        let path = CyclingPath(name: "Test Path",coordinates: [])
        path.setCoordinates(coordinates: CLLocationCoordinate2DArray)
        
        // Then

        for i in 0..<expectedCoordinates.count{
            XCTAssertEqual(path.coordinates[i].latitude, expectedCoordinates[i].latitude)
            XCTAssertEqual(path.coordinates[i].longitude, expectedCoordinates[i].longitude)
        }
    }
    
    func testSetNilCoordinates() {
        // Given
        let CLLocationCoordinate2DArray: [CLLocationCoordinate2D] = []
        
        // When
        let path = CyclingPath(name: "Test Path",coordinates: [])
        path.setCoordinates(coordinates: CLLocationCoordinate2DArray)
        
        // Then
        XCTAssertEqual(path.coordinates.count, 0)
    }
    
    func testSetNilWithPopulatedData() {
        // Given
        let CLLocationCoordinate2DArray: [CLLocationCoordinate2D] = []
        
        // When
        let path = CyclingPath(name: "Test Path",coordinates: [Coordinate(latitude: 45.0, longitude: 45.0), Coordinate(latitude: 46.0, longitude: 46.0)])
        path.setCoordinates(coordinates: CLLocationCoordinate2DArray)
        
        // Then
        XCTAssertEqual(path.coordinates.count, 0)
    }
    
    
    func testGetCoordinates() {
        // Given
        let coordinates = [Coordinate(latitude: 45.0, longitude: 45.0), Coordinate(latitude: 46.0, longitude: 46.0)]
        let expectedCLLocationCoordinate2DArray = [CLLocationCoordinate2D(latitude: 45.0, longitude: 45.0), CLLocationCoordinate2D(latitude: 46.0, longitude: 46.0)]
        
        // When
        let path = CyclingPath(name: "Test Path",coordinates: coordinates)
        let result = path.getCoordinates()
        
        // Then
        for i in 0..<coordinates.count{
            XCTAssertEqual(result[i].latitude, expectedCLLocationCoordinate2DArray[i].latitude)
            XCTAssertEqual(result[i].longitude, expectedCLLocationCoordinate2DArray[i].longitude)
        }
    }
    
    //MARK: Coordinate Angle Tests
    func testAngleNorth(){
        let start = Coordinate(latitude: 0.0, longitude: 0.0)
        let end = Coordinate(latitude: 1.0, longitude: 0)
        let angle = CyclingPath.findNorthRelativeAngle(from: start, to: end)
        XCTAssertEqual(angle, 0, "Angle should be 0 degrees when moving from south to north")
    }
    
    func testAngleEast(){
        let start = Coordinate(latitude: 0.0, longitude: 0.0)
        let end = Coordinate(latitude: 0.0, longitude: 1.0)
        let angle = CyclingPath.findNorthRelativeAngle(from: start, to: end)
        XCTAssertEqual(angle, 90, "Angle should be 90 degrees when moving from west to east")
    }
    
    func testAngleSouth(){
        let start = Coordinate(latitude: 1.0, longitude: 0.0)
        let end = Coordinate(latitude: 0.0, longitude: 0)
        let angle = CyclingPath.findNorthRelativeAngle(from: start, to: end)
        XCTAssertEqual(angle, 180, "Angle should be 180 degrees when moving from north to south")
    }
    
    func testAngleWest(){
        let start = Coordinate(latitude: 0.0, longitude: 1.0)
        let end = Coordinate(latitude: 0.0, longitude: 0.0)
        let angle = CyclingPath.findNorthRelativeAngle(from: start, to: end)
        XCTAssertEqual(angle, 270, "Angle should be 270 degrees when moving from east to west")
    }
    
    func testAngleNormalization(){
        let start = Coordinate(latitude: 0.0, longitude: 0.0)
        let end = Coordinate(latitude: -1.0, longitude: 0.0)
        let angle = CyclingPath.findNorthRelativeAngle(from: start, to: end)
        XCTAssertEqual(angle, 180, "Angle should be normalized to 180 degrees when initially calculated as negative moving from south to north")
    }
    
    
//MARK: Aggrigate Angle tests
    func testSingleDirectionPath() {
           let inputCoordinates = [
               CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
               CLLocationCoordinate2D(latitude: 1.0, longitude: 0.0) // North
           ]
           
           let path = CyclingPath(name: "Single Direction Path")
           path.setCoordinates(coordinates: inputCoordinates)
           
           path.findNorthRelativeAngles()
           XCTAssertEqual(path.coordinateAngles, [0.0], "Path moving straight north should have angles [0.0]")
       }
       
       func testSquarePath() {
           let inputCoordinates = [
               CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), // Starting point
               CLLocationCoordinate2D(latitude: 0.0, longitude: 1.0), // East
               CLLocationCoordinate2D(latitude: -1.0, longitude: 1.0), // South
               CLLocationCoordinate2D(latitude: -1.0, longitude: 0.0)  // West
           ]
           
           let path = CyclingPath(name: "Square Path")
           path.setCoordinates(coordinates: inputCoordinates)
           
           path.findNorthRelativeAngles()
           XCTAssertEqual(path.coordinateAngles, [90.0, 180.0, 270.0], "Path forming a square should have angles [90.0, 180.0, 270.0]")
       }
       
    func testComplexPath() {
        let inputCoordinates = [
            CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), // Northeast
            CLLocationCoordinate2D(latitude: 0.0, longitude: 2.0), // West from the second point
            CLLocationCoordinate2D(latitude: -1.0, longitude: 1.0)  // South from the third point
        ]
        
        let path = CyclingPath(name: "Complex Path")
        path.setCoordinates(coordinates: inputCoordinates)
        
        path.findNorthRelativeAngles()
        let expectedAngles = [45.0, 135.0, 225.0] // Corrected expected angles
        for (index, angle) in path.coordinateAngles.enumerated() {
            XCTAssertEqual(angle, expectedAngles[index], accuracy: 0.5, "Angle at index \(index) should be close to \(expectedAngles[index])")
        }
    }
       
       func testPathWithNoMovement() {
           let inputCoordinates = [
               CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
           ]
           
           let path = CyclingPath(name: "No Movement")
           path.setCoordinates(coordinates: inputCoordinates)
           
           path.findNorthRelativeAngles()
           XCTAssertTrue(path.coordinateAngles.isEmpty, "Path with no movement should have an empty angles array")
       }
       
       func testPathWithBacktracking() {
           let inputCoordinates = [
               CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
               CLLocationCoordinate2D(latitude: 1.0, longitude: 0.0), // North
               CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)  // Back to start (South)
           ]
           
           let path = CyclingPath(name: "Backtracking Path")
           path.setCoordinates(coordinates: inputCoordinates)
           
           path.findNorthRelativeAngles()
           XCTAssertEqual(path.coordinateAngles, [0.0, 180.0], "Path with backtracking should accurately reflect reverse direction")
       }
    
}

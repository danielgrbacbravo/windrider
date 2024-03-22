//
//  ImpactVisualizer.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 22/03/2024.
//

import Foundation
import SwiftUI


/// ImpactVisualizer is a class that provides functions to help visualize the impact of weather on a cycling path, such as constructing a polyline segment for each pair of coordinates in the cycling path.
enum ImpactVisualizer{
  
  //MARK: Map Related Functions 
  /// Constructs a polyline segment for each pair of coordinates in the cycling path
  /// - Parameters:
  ///   - coordinateImpacts: Array of CoordinateImpact objects
  ///   - cyclingPath: CyclingPath object
  /// - Returns: Array of PolylineSegement objects
  ///
  /// The polyline segments are colored based on the headwind percentage of the CoordinateImpact objects. The color is calculated using the headwindPercentageToColor function.
  static public func constructWeatherImpactPolyline( _ coordinateImpacts: [CoordinateImpact], cyclingPath: CyclingPath) -> [PolylineSegement] {
    var polylineSegments: [PolylineSegement] = []
    let coordinates = cyclingPath.getCoordinates()
    
    // Iterate through the coordinateWeatherImpacts and create a polyline segment for each pair of coordinates
    for i in 0..<coordinateImpacts.count {
      var color: Color = .gray
      
      if i < coordinates.count - 1 {
        var currentLength = ImpactCalculator.calculatePathLength([cyclingPath.coordinateVectors[i], cyclingPath.coordinateVectors[i+1]])
        color = headwindPercentageToColor(coordinateImpacts[i].headwind/currentLength)
        let segmentCoordinates = [coordinates[i], coordinates[i+1]]
        let segment = PolylineSegement(CoordinateArray: segmentCoordinates, Color: color)
        polylineSegments.append(segment)
      }
    }
    return polylineSegments
  }
  
  static public func headwindPercentageToColor(_ percentage: Float) -> Color {
    let redValue = percentage / 100
    let greenValue = 1 - redValue
    return Color(red: Double(redValue), green: Double(greenValue), blue: 0)
  }
  
  
  ///  Constructs a message to inform the user about the impact of weather on the cycling path
  /// - Parameter pathWeatherImpact: PathImpact object
  /// - Returns: String message
  ///
  /// The message is constructed based on the wind speed, temperature, and wind direction of the PathImpact object. The message is constructed by concatenating different strings based on the weather conditions.
  ///
  ///  ## Example Usage
  ///
  ///  ```swift
  ///  let pathWeatherImpact = PathImpact(temperature: 298, windSpeed: 10, headwindPercentage: 70, tailwindPercentage: 10, crosswindPercentage: 20)
  ///  let message = ImpactVisualizer.constructCyclingMessage(for: pathWeatherImpact)
  ///  Print(message)
  ///  ```
  ///   The message will be:
  ///  ```text
  ///  The temperature is 25°C, which is great for cycling. However, the wind speed is 10 m/s, making it a bad day to cycle. 70% of your ride is against the wind.
  ///  ```
  static public func constructCyclingMessage(for pathWeatherImpact: PathImpact) -> String {
    let headwindPercentage = pathWeatherImpact.headwindPercentage
    let tailwindPercentage = pathWeatherImpact.tailwindPercentage
    let crosswindPercentage = pathWeatherImpact.crosswindPercentage
    let windSpeed = pathWeatherImpact.windSpeed
    let temperatureKelvin = pathWeatherImpact.temperature
    let temperatureCelsius = temperatureKelvin - 273.15
    
    
    // calm weather
    if windSpeed < 2 {
      let temperatureMessage: String
      if temperatureCelsius > 20 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, making it a great day to cycle."
      } else if temperatureCelsius > 10 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, making it a good day to cycle."
      } else {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, making it a cold day to cycle."
      }
      let windMessage = "The weather is calm with no wind."
      return [temperatureMessage, windMessage].joined(separator: " ")
    }
    
    // mildly windy weather
    if windSpeed < 5 {
      let temperatureMessage: String
      if temperatureCelsius > 20 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, making it a great day to cycle."
      } else if temperatureCelsius > 10 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, making it a good day to cycle."
      } else {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, making it a cold day to cycle."
      }
      let windMessage = "The wind speed is \(Int(windSpeed)) m/s, which is quite mild."
      return [temperatureMessage, windMessage].joined(separator: " ")
    }
    
    // windy weather
    if windSpeed < 10 {
      let temperatureMessage: String
      if temperatureCelsius > 20 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, which is great for cycling. However,"
      } else if temperatureCelsius > 10 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, which is good for cycling. However,"
      } else {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, and"
      }
      
      var windDirectionMessage = ""
      
      if headwindPercentage > 50 {
        windDirectionMessage.append("\(Int(headwindPercentage))% of your ride is against the wind.")
      }
      if tailwindPercentage > 50 {
        windDirectionMessage.append("\(Int(tailwindPercentage))% of your ride is with the wind.")
      }
      if crosswindPercentage > 50 {
        windDirectionMessage.append("\(Int(crosswindPercentage))% of your ride is across the wind.")
      }
      
      let windMessage = "the wind speed is \(Int(windSpeed)) m/s, which is not ideal for cycling. "
      
      return [temperatureMessage, windMessage, windDirectionMessage].joined(separator: " ")
    }
    
    // very windy weather
    if windSpeed > 15 {
      let temperatureMessage: String
      if temperatureCelsius > 20 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, but"
      } else if temperatureCelsius > 10 {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, but"
      } else {
        temperatureMessage = "The temperature is \(Int(temperatureCelsius))°C, and"
      }
      let windMessage = "the wind speed is \(Int(windSpeed)) m/s, making it a bad day to cycle. "
      
      var windDirectionMessage = ""
      
      if headwindPercentage > 50 {
        windDirectionMessage.append("\(Int(headwindPercentage))% of your ride is against the wind.")
      }
      if tailwindPercentage > 50 {
        windDirectionMessage.append("\(Int(tailwindPercentage))% of your ride is with the wind.")
      }
      if crosswindPercentage > 50 {
        windDirectionMessage.append("\(Int(crosswindPercentage))% of your ride is across the wind.")
      }
      
      return [temperatureMessage, windMessage, windDirectionMessage].joined(separator: " ")
    }
    
    // this should never be reached
    return "It is not a good day to cycle."
    
  }
  
}

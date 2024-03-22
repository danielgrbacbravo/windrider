//
//  ImpactCalculator.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 22/03/2024.
//

import Foundation

///  this enum provides a set of functions to calculate the impact of weather conditions on a set of coordinates. The function uses the wind direction from an ``OpenWeatherMapResponse`` to calculate the headwind, crosswind, and tailwind for each coordinate in a given array of 2D vectors (coordinates). The impacts are returned as an array of ``CoordinateImpact`` objects.
enum ImpactCalculator {
  
  /// calculates the impact of weather conditions on a set of coordinates. It uses the wind direction from an ``OpenWeatherMapResponse`` to calculate the headwind, crosswind, and tailwind for each coordinate in a given array of 2D vectors (coordinates). The impacts are returned as an array of ``CoordinateImpact`` objects.
  ///
  ///- Parameters:
  ///   - coordinateVectors: An array of  2D vectors representing coordinates. Each vector consists of two float values.
  ///   - openWeatherMapResponce: An instance of OpenWeatherMapResponse that contains weather data, including wind direction.
  /// - Returns: An array of ``CoordinateImpact`` objects. Each object represents the impact of weather conditions on a specific coordinate, including headwind, crosswind, and tailwind values.
  ///
  /// - Note: The function uses the wind direction to calculate the impact of weather conditions on each coordinate. The wind direction is used to rotate the coordinate vector, and the headwind, crosswind, and tailwind are calculated based on the rotated vector.
  ///
  /// #  Example Usage
  ///  ``` swift
  ///  let coordinateVectors = [SIMD2<Float>(1, 0), SIMD2<Float>(0, 1)]
  ///  let openWeatherMapResponce = OpenWeatherMapResponse(wind: Wind(speed: 10, deg: 90))
  ///  let impacts = ImpactCalculator.calculateWeatherImpactOnCoordinates(coordinateVectors, with: openWeatherMapResponce)
  ///  ```
  ///  In this example, the function calculates the impact of weather conditions on two coordinates (1, 0) and (0, 1) with a wind direction of 90 degrees. The headwind, crosswind, and tailwind values are calculated based on the wind direction and returned as an array of ``CoordinateImpact`` objects.
  static public func calculateWeatherImpactOnCoordinates(_ coordinateVectors: [SIMD2<Float>], with openWeatherMapResponce: OpenWeatherMapResponse ) -> [CoordinateImpact] {
    
    let windDirection = openWeatherMapResponce.wind.deg
    var coordinateImpacts: [CoordinateImpact] = []
    
    for coordinateVector in coordinateVectors {
      let relativeCoordinateVector = rotateVector(vector: coordinateVector, angle: Float(windDirection))
      
      let headwind = calculateHeadwindFromVector(relativeCoordinateVector)
      let crosswind = calculateCrosswindFromVector(relativeCoordinateVector)
      let tailwind = calculateTailwindFromVector(relativeCoordinateVector)
      
      let coordinateImpact = CoordinateImpact( headwind: headwind, crosswind: crosswind, tailwind: tailwind)
      coordinateImpacts.append(coordinateImpact)
    }
    return coordinateImpacts
  }
  
  
  /// calculates the impact of weather conditions on a path. It uses an array of ``CoordinateImpact`` objects and an array of 2D vectors representing the path to calculate the overall impact of weather conditions on the path. The function returns a ``PathImpact`` object that represents the overall impact of weather conditions on the path.
  /// - Parameters:
  ///   - coordinateImpacts: An array of ``CoordinateImpact`` objects. Each object represents the impact of weather conditions on a specific coordinate, including headwind, crosswind, and tailwind values.
  ///   - coordinateVectors: An array of 2D vectors representing the path. Each vector consists of two float values.
  /// - Returns: A ``PathImpact`` object that represents the overall impact of weather conditions on the path, including headwind, crosswind, and tailwind percentages.
  ///
  /// - Note: The function calculates the total headwind, crosswind, and tailwind values for all coordinates in the path. The total values are then divided by the total path length to calculate the headwind, crosswind, and tailwind percentages.
  ///
  /// # Example Usage
  /// ``` swift
  /// let coordinateVectors = [SIMD2<Float>(1, 0), SIMD2<Float>(0, 1)]
  /// let openWeatherMapResponce = OpenWeatherMapResponse(wind: Wind(speed: 10, deg: 90))
  /// let impacts = ImpactCalculator.calculateWeatherImpactOnCoordinates(coordinateVectors, with: openWeatherMapResponce)
  /// let pathImpact = ImpactCalculator.calculateWeatherImpactOnPath(impacts, coordinateVectors: coordinateVectors)
  /// ```
  /// In this example, the function calculates the impact of weather conditions on two coordinates (1, 0) and (0, 1) with a wind direction of 90 degrees. The headwind, crosswind, and tailwind values are calculated based on the wind direction and returned as an array of ``CoordinateImpact`` objects. The function then calculates the overall impact of weather conditions on the path and returns a ``PathImpact`` object.
  static public func calculateWeatherImpactOnPath(_ coordinateImpacts: [CoordinateImpact],  coordinateVectors: [SIMD2<Float>]) -> PathImpact {
    
    var headwindSum: Float = 0
    var crosswindSum: Float = 0
    var tailwindSum: Float = 0
    
    for coordinateImpact in coordinateImpacts {
      headwindSum += coordinateImpact.headwind
      crosswindSum += coordinateImpact.crosswind
      tailwindSum += coordinateImpact.tailwind
    }
    
    let totalPathLength = calculatePathLength(coordinateVectors)
    
    let headwindPercentage = Int(headwindSum/totalPathLength)
    let crosswindPercentage = Int(crosswindSum/totalPathLength)
    let tailwindPercentage = Int(tailwindSum/totalPathLength)
    
    return PathImpact(headwindPercentage: headwindPercentage, crosswindPercentage: crosswindPercentage, tailwindPercentage: tailwindPercentage)
    
  }
  
  
  /// calculates the length of a path based on an array of 2D vectors representing the path.
  /// - Parameter coordinateVectors: An array of 2D vectors representing the path. Each vector consists of two float values.
  /// - Returns: The total length of the path.
  static public func calculatePathLength(_ coordinateVectors: [SIMD2<Float>] ) -> Float{
    var totalLength: Float = 0
    for coordinateVector in coordinateVectors {
      totalLength += sqrtf(powf(coordinateVector.x, 2) + powf(coordinateVector.y,2))
    }
    return totalLength
  }
  
  
  static public func rotateVector(vector: SIMD2<Float>, angle: Float) -> SIMD2<Float> {
    let x = vector.x * cos(angle) - vector.y * sin(angle)
    let y = vector.x * sin(angle) + vector.y * cos(angle)
    return SIMD2<Float>(x, y)
  }
  
  
  
  /// Calculates the headwind value based on a 2D vector representing the path.
  /// - Parameter coordinateVector: A 2D vector representing the path. The vector consists of two float values.
  /// - Returns: The headwind score for  that vector.
  static public func calculateHeadwindFromVector(_ coordinateVector: SIMD2<Float> ) -> Float {
    // Calculate the length of the vector
    let length = Float(sqrt(pow(coordinateVector.x,2) + pow(coordinateVector.y,2)))
    // Calculate the angle in radians
    let angleRad = atan2(coordinateVector.y, coordinateVector.x)
    // Convert the angle to degrees
    let angleDeg = angleRad * 180 / Float.pi
    // Adjust the angle to be between 0 and 360
    let adjustedAngleDeg = angleDeg < 0 ? angleDeg + 360 : angleDeg
    // Calculate the headwind score
    if (adjustedAngleDeg > 270 || (adjustedAngleDeg > 0 && adjustedAngleDeg < 90)) {
      let thetaRad = Double(adjustedAngleDeg) * Double.pi / 180
      let percentage = Float((1 + cos(thetaRad)) / 2)
      return Float(length * percentage * 100)
    }
    return 0
  }
  /// Calculates the crosswind value based on a 2D vector representing the path.
  /// - Parameter coordinateVector: A 2D vector representing the path. The vector consists of two float values.
  /// - Returns: The crosswind score for  that vector.
  static public func calculateCrosswindFromVector(_ coordinateVector: SIMD2<Float>) -> Float {
    // Calculate the length of the vector
    let length = Float(sqrt(pow(coordinateVector.x,2) + pow(coordinateVector.y,2)))
    // Calculate the angle in radians
    let angleRad = atan2(coordinateVector.y, coordinateVector.x)
    // Convert the angle to degrees
    let angleDeg = angleRad * 180 / Float.pi
    // Adjust the angle to be between 0 and 360
    let adjustedAngleDeg = angleDeg < 0 ? angleDeg + 360 : angleDeg
    // Calculate the crosswind score
    if (adjustedAngleDeg > 0 && adjustedAngleDeg < 180) {
      let thetaRad = Double(adjustedAngleDeg) * Double.pi / 180
      let percentage = Float((1 - cos(2 * thetaRad)) / 2)
      return Float (length * percentage *  100)
    }
    return 0
  }
  
  /// Calculates the tailwind value based on a 2D vector representing the path.
  /// - Parameter coordinateVector: A 2D vector representing the path. The vector consists of two float values.
  /// - Returns: The tailwind score for  that vector.
  static public func calculateTailwindFromVector(_ coordinateVector: SIMD2<Float>) -> Float {
    // Calculate the length of the vector
    let length = Float(sqrt(pow(coordinateVector.x,2) + pow(coordinateVector.y,2)))
    // Calculate the angle in radians
    let angleRad = atan2(coordinateVector.y, coordinateVector.x)
    // Convert the angle to degrees
    let angleDeg = angleRad * 180 / Float.pi
    // Adjust the angle to be between 0 and 360
    let adjustedAngleDeg = angleDeg < 0 ? angleDeg + 360 : angleDeg
    // Calculate the tailwind score
    if (adjustedAngleDeg > 90 && adjustedAngleDeg < 270) {
      let thetaRad = Double(adjustedAngleDeg) * Double.pi / 180
      let percentage = Float((1 + cos(thetaRad)) / 2)
      return Float (length * percentage * 100)
    }
    return 0
    
  }
  
  /// cycling score is a custom holistic score that combines the weather impact on the path.
  ///
  /// - Parameter pathWeatherImpact: A `PathWeatherImpact` object representing the cumulative weather impact on the path.
  /// - Returns: A double representing the weather impact on the path.
  static public func calculateCyclingScore(for pathWeatherImpact: PathImpact) -> Int {
    //constants used for normalization of the score
    
    guard let defaults = UserDefaults(suiteName: "group.com.daiigr.windrider") else {
      return 0
    }
    
    let upperTemprature: Float = Float(defaults.double(forKey: "upperTemperature"))
    let idealTemprature: Float = Float(defaults.double(forKey: "idealTemperature"))
    let upperWindSpeed: Float = Float(defaults.double(forKey: "upperWindSpeed"))
    
    // weights used
    // TODO: make these values accessible in the config (to be implemented)
    let headwindWeight: Float = Float(defaults.double(forKey: "headwindWeight"))
    let tailwindWeight: Float = Float(defaults.double(forKey: "tailwindWeight"))
    let crosswindWeight: Float = Float(defaults.double(forKey: "crosswindWeight"))
    
    let temperatureImpact = Float(pathWeatherImpact.temperature) - idealTemprature
    let windSpeedImpact = pathWeatherImpact.windSpeed
    // extract the wind direction percentages
    var headwindPercentage: Float = Float(pathWeatherImpact.headwindPercentage)
    var crosswindPercentage: Float = Float(pathWeatherImpact.crosswindPercentage)
    var tailwindPercentage: Float = Float(pathWeatherImpact.tailwindPercentage)
    // consider the wind direction percentages
    headwindPercentage *= headwindWeight
    crosswindPercentage *= crosswindWeight
    tailwindPercentage *= tailwindWeight
    let windDirectionImpact: Float = headwindPercentage - tailwindPercentage + crosswindWeight
    let score = (temperatureImpact * windSpeedImpact) + (pow(windSpeedImpact,2)) + windDirectionImpact
    
    //normalization of score
    let maxTemperatureImpact:Float = abs(upperTemprature - idealTemprature)
    let maxWindSpeedImpact: Float = upperWindSpeed
    let maxWindDirectionImpact: Float = 1
    let maxScore: Float = (maxTemperatureImpact * maxWindSpeedImpact) + (pow(maxWindSpeedImpact, 2)) + maxWindDirectionImpact
    let minScore:Float = 0.0
    let normalizedScore = (score - minScore) / (maxScore - minScore)
    
    return Int(normalizedScore * 100)
  }
}


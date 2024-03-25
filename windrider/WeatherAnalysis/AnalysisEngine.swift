//
//  AnalysisEngine.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 22/03/2024.
//

import Foundation
/// AnalysisEngine is a class that provides functions to analyse the impact of weather on a cycling path, such as computing the impact of weather on each coordinate and the path as a whole.
enum AnalysisEngine {
  
  
  /// Analyse the impact of weather on a cycling path
  /// - Parameters:
  ///   - cyclingPath: cycling path to analyse
  ///   - openWeatherMapAPI: OpenWeatherMapAPI object which is used to fetch the weather conditions
  ///   - completion: completion handler that returns the result of the analysis
  ///
  /// The function fetches the weather conditions for the average coordinate of the cycling path and then computes the impact of the weather on each coordinate and the path as a whole.
  ///
  /// ## Example usage
  ///
  /// ```swift
  /// let cyclingPath = CyclingPath(coordinates: [Coordinate(latitude: 45.5, longitude: 15.5), Coordinate(latitude: 45.6, longitude: 15.6)])
  /// let openWeatherMapAPI = OpenWeather
  /// AnalysisEngine.analyseImpact(for: cyclingPath, with: openWeatherMapAPI) { result in
  ///   switch result{
  ///   case .success(let coordinateWeatherImpacts, let pathWeatherImpact):
  ///   print(coordinateWeatherImpacts)
  ///   print(pathWeatherImpact)
  ///   case .failure(let error):
  ///   print(error)
  ///   }
  ///  }
  ///  ```
  /// The function will return an array of CoordinateWeatherImpact objects and a PathWeatherImpact object.
  static public func analyseImpact(for cyclingPath: CyclingPath, with openWeatherMapAPI: OpenWeatherMapAPI, completion: @escaping (Result<([CoordinateImpact], PathImpact), Error>) -> Void){
    /// checks if the average coordinate is valid
    guard let averageCoordinate = cyclingPath.getAverageCoordinate() else {
      completion(.failure(AnalysisEngineError.invalidAverageCoordinate))
      return
    }
    /// fetch the weather conditions for the average coordinate of the cycling path
    openWeatherMapAPI.fetchWeatherConditions(for:averageCoordinate) { result in
      switch result{
        case .success(let response):
          let coordinateImpacts = ImpactCalculator.calculateWeatherImpactOnCoordinates(cyclingPath.coordinateVectors, with: response)
          var pathImpact = ImpactCalculator.calculateWeatherImpactOnPath(coordinateImpacts, coordinateVectors: cyclingPath.getVectors())
          pathImpact.temperature = Float(response.main.temp)
          pathImpact.windSpeed = Float(response.wind.speed)
          pathImpact.cyclingScore = ImpactCalculator.calculateCyclingScore(for: pathImpact)
          pathImpact.cyclingMessage = ImpactVisualizer.constructCyclingMessage(for: pathImpact)
          completion(.success((coordinateImpacts, pathImpact)))
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }
}

enum AnalysisEngineError: Error{
  case invalidAverageCoordinate
}

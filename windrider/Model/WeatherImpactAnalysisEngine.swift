//
//  WeatherImpactAnalysisEngine.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation
import CoreLocation
class WeatherImpactAnalysisEngine{
    
    //MARK: Data Processing
    /**
     Fetches weather impact analysis for a cycling path.

     - Parameters:
        - cyclingPath: The cycling path for which weather impact analysis is to be fetched.
        - openWeatherMapAPI: An instance of `OpenWeatherMapAPI` used to fetch weather conditions.
        - completion: A closure called upon completion of the weather impact analysis, returning a `Result` containing either an array of `CoordinateWeatherImpact` objects representing the weather impacts on each coordinate and a `PathWeatherImpact` object representing the cumulative weather impact on the path, or an error if the operation fails.s
     */
    public func analyseImpact(for cyclingPath: CyclingPath, with openWeatherMapAPI: OpenWeatherMapAPI, completion: @escaping (Result<([CoordinateWeatherImpact], PathWeatherImpact), Error>) -> Void){
        
        /// checks if the average coordinate is valid
        guard let averageCoordinate = cyclingPath.getAverageCoordinate() else {
            completion(.failure(WeatherImpactAnalysisEngineError.invalidAverageCoordinate))
            return
        }
        
        /// fetch the weather conditions for the average coordinate of the cycling path
        openWeatherMapAPI.fetchWeatherConditions(for:averageCoordinate) { result in
            switch result{
            case .success(let response):
                /// state: the response is valid
                var coordinateWeatherImpacts: [CoordinateWeatherImpact] = []
                var pathWeatherImpact: PathWeatherImpact
        
                coordinateWeatherImpacts = WeatherImpactAnalysisEngine.computeCoordinateWeatherImpacts(for: cyclingPath.coordinateAngles, with: response)
                
                pathWeatherImpact = WeatherImpactAnalysisEngine.computePathWeatherImpact(for: coordinateWeatherImpacts, with: response)
                
                completion(.success((coordinateWeatherImpacts, pathWeatherImpact)))
      
            case .failure(let error):
                /// state: the response is invalid
                completion(.failure(error))
            }
        }
    }

    /**
     Computes the weather impacts on coordinates based on wind direction and speed.

     - Parameters:
        - coordinateAngles: An array of integers representing the angles of coordinates.
        - openWeatherMapResponce: An instance of `OpenWeatherMapResponse` containing wind information.

     - Returns: An array of `CoordinateWeatherImpact` objects representing the weather impacts on each coordinate.
     */
    static public func computeCoordinateWeatherImpacts(for coordinateAngles: [Int], with openWeatherMapResponce: OpenWeatherMapResponse ) -> [CoordinateWeatherImpact] {
        var coordinateWeatherImpacts: [CoordinateWeatherImpact] = []

        for coordinateAngle in coordinateAngles {
            /// Find the relative wind angle
            let relativeWindAngle = WeatherImpactAnalysisEngine.findRelativeWindAngle(coordinateAngle: coordinateAngle, windAngle: openWeatherMapResponce.wind.deg)

            /// Compute the headwind, tailwind, and crosswind percentages
            let headwindPercentage = WeatherImpactAnalysisEngine.computeHeadwindPercentage(for: relativeWindAngle)
            let tailwindPercentage = WeatherImpactAnalysisEngine.findTailwindPercentage(relativeWindAngle: relativeWindAngle)
            let crosswindPercentage = WeatherImpactAnalysisEngine.findCrosswindPercentage(relativeWindAngle: relativeWindAngle)

            /// Construct the `CoordinateWeatherImpact` object
            let coordinateWeatherImpact = CoordinateWeatherImpact(relativeWindDirectionInDegrees: Double(relativeWindAngle), headwindPercentage: Double(headwindPercentage), tailwindPercentage: Double(tailwindPercentage), crosswindPercentage: Double(crosswindPercentage))

            coordinateWeatherImpacts.append(coordinateWeatherImpact)
        }

        return coordinateWeatherImpacts
    }

    /**
     Computes the weather impact on the path based on wind direction and speed.

     - Parameters:
        - coordinateWeatherImpacts: An array of `CoordinateWeatherImpact` objects representing the weather impacts on each coordinate.
        - openWeatherMapResponse: An instance of `OpenWeatherMapResponse` containing wind information.

     - Returns: A `PathWeatherImpact` object representing the cumulative weather impact on the path.
     */
    static public func computePathWeatherImpact(for coordinateWeatherImpacts: [CoordinateWeatherImpact], with openWeatherMapResponse: OpenWeatherMapResponse) -> PathWeatherImpact {
        var totalHeadwindPercentage = 0.0
        var totalCrosswindPercentage = 0.0
        var totalTailwindPercentage = 0.0
        /// compute the sum of headwind, crosswind, and tailwind percentages
        for coordinateWeatherImpact in coordinateWeatherImpacts {
            totalHeadwindPercentage += coordinateWeatherImpact.headwindPercentage ?? 0.0
            totalCrosswindPercentage += coordinateWeatherImpact.crosswindPercentage ?? 0.0
            totalTailwindPercentage += coordinateWeatherImpact.tailwindPercentage ?? 0.0
        }
        /// compute the average of headwind, crosswind, and tailwind percentages
        totalHeadwindPercentage /= Double(coordinateWeatherImpacts.count)
        totalCrosswindPercentage /= Double(coordinateWeatherImpacts.count)
        totalTailwindPercentage /= Double(coordinateWeatherImpacts.count)
        /// Construct the `PathWeatherImpact` object
        let pathWeatherImpact = PathWeatherImpact(temperature: openWeatherMapResponse.main.temp, windSpeed: openWeatherMapResponse.wind.speed, headwindPercentage: totalHeadwindPercentage, tailwindPercentage: totalTailwindPercentage, crosswindPercentage: totalCrosswindPercentage)

        return pathWeatherImpact
    }

    
    
    static private func computeHeadwindPercentage(for relativeWindAngle: Int) -> Int{
        if((relativeWindAngle > 260) || (relativeWindAngle > 0 && relativeWindAngle < 90)){
            let thetaRad = Double(relativeWindAngle) * Double.pi / 180
            return Int ((1 + cos(thetaRad)) / 2 * 100)
        }
        return 0
    }
    static private func findCrosswindPercentage(relativeWindAngle: Int) -> Int{
        let thetaRad = Double(relativeWindAngle) * Double.pi / 180
        return Int((1 - cos(2 * thetaRad)) / 2 * 100)
    }
    
    static private func findTailwindPercentage(relativeWindAngle: Int) -> Int {
        if((relativeWindAngle > 90) && (relativeWindAngle < 260)){
            let thetaRad = Double(relativeWindAngle) * Double.pi / 180
            return Int ((1 + cos(thetaRad)) / 2 * 100)
        }
        return 0
    }
    
   static private func findRelativeWindAngle(coordinateAngle: Int, windAngle: Int) -> Int {
        var relativeWindAngle: Int = windAngle - coordinateAngle
        // if the result is negative, add 360 to bring it within the 0 to 360 range
        if relativeWindAngle < 0 {
            relativeWindAngle += 360
        }
        // Ensure the result is within the 0 to 360 range
        relativeWindAngle %= 360
        return relativeWindAngle
    }
    
    enum WeatherImpactAnalysisEngineError: Error {
        case invalidAverageCoordinate
    }
    
    
    //MARK: Data Representation
    
    
    /// a holistic score representing the weather impact on the path
    ///
    /// - Parameter pathWeatherImpact: A `PathWeatherImpact` object representing the cumulative weather impact on the path.
    /// - Returns: A double representing the weather impact on the path.
    static public func cyclingScore(for pathWeatherImpact: PathWeatherImpact) -> Double {
        let idealTemperature = 20.0
        let temperatureImpact = 1 / (1 + exp(-(pathWeatherImpact.temperature - idealTemperature)))
        
        let idealWindSpeed = 0.0
        let windSpeedImpact = 1 / (1 + exp(-(pathWeatherImpact.windSpeed - idealWindSpeed)))
        
        let windImpact = (pathWeatherImpact.tailwindPercentage ?? 0) - (pathWeatherImpact.headwindPercentage ?? 0) - (pathWeatherImpact.crosswindPercentage ?? 0)
        let normalizedWindImpact = (windImpact + 100) / 200 // normalize to 0-1 range
        
        let score = (temperatureImpact + windSpeedImpact + normalizedWindImpact) / 3
        return score
    }
    
    
    /// Returns a string indicating whether it is a good day to cycle based on the weather impact on the path.
    ///
    /// - Parameter pathWeatherImpact: A `PathWeatherImpact` object representing the cumulative weather impact on the path.
    /// - Returns: A string indicating whether it is a good day to cycle.
    static public func shouldICycle(for pathWeatherImpact: PathWeatherImpact) -> String {
        guard let headwindPercentage = pathWeatherImpact.headwindPercentage,
              let tailwindPercentage = pathWeatherImpact.tailwindPercentage,
              let crosswindPercentage = pathWeatherImpact.crosswindPercentage
        else {
            return "Data is incomplete"
        }

        let windSpeed = pathWeatherImpact.windSpeed
        let temperature = pathWeatherImpact.temperature

        if windSpeed > 10 {
            return "It's quite windy today. Cycling might be challenging."
        }
        if temperature < 0 {
            return "It's freezing outside. Cycling might be uncomfortable."
        }
        if headwindPercentage > 50 {
            return "There's a strong headwind today. Cycling could be difficult."
        }
        if crosswindPercentage > 50 {
            return "There's a strong crosswind today. It could make cycling unstable."
        }
        if tailwindPercentage > 50 {
            if temperature > 30 {
                return "It's a warm day with a nice tailwind. Remember to stay hydrated while cycling."
            } else {
                return "It's a good day to cycle with a supportive tailwind."
            }
        }
        if temperature > 30 {
            return "It's quite hot today. If you decide to cycle, remember to stay hydrated."
        }
        return "The weather seems good for cycling. Enjoy your ride!"
    }
    
}


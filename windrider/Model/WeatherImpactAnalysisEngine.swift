//
//  WeatherImpactAnalysisEngine.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation
import CoreLocation
class WeatherImpactAnalysisEngine{
   
    /// Fetches the current weather conditions for the average coordinate of the given cycling path and computes the weather impact for each coordinate.
    /// - Parameters:
    ///  - cyclingPath: The cycling path for which to compute the weather impact.
    ///  - OpenWeatherMapAPI: The OpenWeatherMapAPI to use to fetch the weather conditions.
    ///  - completion: The completion block to call when the weather impact has been computed.
    private func fetchCoordinateWeatherImpact(for cyclingPath: CyclingPath, with openWeatherMapAPI: OpenWeatherMapAPI, completion: @escaping (Result<[CoordinateWeatherImpact], Error>) -> Void){
        
        //unwrapping the average coordinate
        guard let averageCoordinate = cyclingPath.getAverageCoordinate() else {
            completion(.failure(WeatherImpactAnalysisEngineError.invalidAverageCoordinate))
            return
        }
        
        // Fetch the weather conditions for the average coordinate of the cycling path
        openWeatherMapAPI.fetchWeatherConditions(for:averageCoordinate) { result in
            switch result {
            case .success(let weatherCondition):
                var coordinateWeatherImpacts: [CoordinateWeatherImpact] = []
                for  coordinateAngle in cyclingPath.coordinateAngles {
                    let relativeWindAngle = self.findRelativeWindAngle(coordinateAngle: coordinateAngle, windAngle: weatherCondition.wind.deg)
                    
                    let headwindPercentage = self.computeHeadwindPercentage(for: relativeWindAngle)
                    
                    let tailwindPercentage = self.findTailwindPercentage(relativeWindAngle: relativeWindAngle)
                    
                    let crosswindPercentage = self.findCrosswindPercentage(relativeWindAngle: relativeWindAngle)
                    
                    let coordinateWeatherImpact = CoordinateWeatherImpact(relativeWindDirectionInDegrees: Double(relativeWindAngle), headwindPercentage: Double(headwindPercentage), tailwindPercentage: Double(tailwindPercentage), crosswindPercentage: Double(crosswindPercentage))
                    
                    coordinateWeatherImpacts.append(coordinateWeatherImpact)
                    
                }
                completion(.success(coordinateWeatherImpacts))
            case . failure(_):
                completion(.failure(WeatherImpactAnalysisEngineError.invalidAverageCoordinate))
                
                
            }
        }
       
    }
    private func computeHeadwindPercentage(for relativeWindAngle: Int) -> Int{
        if((relativeWindAngle > 260) || (relativeWindAngle > 0 && relativeWindAngle < 90)){
            let thetaRad = Double(relativeWindAngle) * Double.pi / 180
            return Int ((1 + cos(thetaRad)) / 2 * 100)
        }
        return 0
    }
    private func findCrosswindPercentage(relativeWindAngle: Int) -> Int{
        let thetaRad = Double(relativeWindAngle) * Double.pi / 180
        return Int((1 - cos(2 * thetaRad)) / 2 * 100)
    }
    
    private func findTailwindPercentage(relativeWindAngle: Int) -> Int {
        if((relativeWindAngle > 90) && (relativeWindAngle < 260)){
            let thetaRad = Double(relativeWindAngle) * Double.pi / 180
            return Int ((1 + cos(thetaRad)) / 2 * 100)
        }
        return 0
    }
    
    private func findRelativeWindAngle(coordinateAngle: Int, windAngle: Int) -> Int {
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
    
}


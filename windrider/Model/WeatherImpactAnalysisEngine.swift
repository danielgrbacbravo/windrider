//
//  WeatherImpactAnalysisEngine.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 09/03/2024.
//

import Foundation
import CoreLocation
class WeatherImpactAnalysisEngine{
   
    // check the completion block (not sure if its correct)
    private func fetchAndComputeCoordinateWeatherImpacts(for cyclingPath: CyclingPath, with OpenWeatherMapAPI: OpenWeatherMapAPI, completion: @escaping ([CoordinateWeatherImpact]?) -> Void) {
        
        guard let averageCoordinate = cyclingPath.getAverageCoordinate() else {
            completion(nil)
            return
        }
        
        var coordinateWeatherImpacts: [CoordinateWeatherImpact] = []
        
        OpenWeatherMapAPI.fetchWeatherConditions(for: averageCoordinate) { result in
            switch result {
            case .success(let weatherResponse):
                for coordinateAngle in cyclingPath.coordinateAngles {
                    let relativeWindAngle = self.findRelativeWindAngle(coordinateAngle: coordinateAngle, windAngle: weatherResponse.wind.deg)
                    
                    let headwindPercentage = self.computeHeadwindPercentage(for: relativeWindAngle)
                    
                    let tailwindPercentage = self.findTailwindPercentage(relativeWindAngle: relativeWindAngle)
                    
                    let crosswindPercentage = self.findCrosswindPercentage(relativeWindAngle: relativeWindAngle)
                    
                    let coordinateWeatherImpact = CoordinateWeatherImpact(relativeWindDirectionInDegrees: Double(relativeWindAngle), headwindPercentage: Double(headwindPercentage), tailwindPercentage: Double(tailwindPercentage), crosswindPercentage: Double(crosswindPercentage))
                    
                    coordinateWeatherImpacts.append(coordinateWeatherImpact)
                }
            completion(coordinateWeatherImpacts)
            
                
            case .failure(_):
                completion(nil)
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
    
}


//
//  OpenWeatherMap.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 02/03/2024.
//

import Foundation
import CoreLocation

// Define your weatherCondition struct
struct WeatherCondition: Decodable {
    var windSpeed: Double
    var windDirection: Double

    enum CodingKeys: String, CodingKey {
        case wind
    }

    struct Wind: Decodable {
        var speed: Double
        var deg: Double
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wind = try container.decode(Wind.self, forKey: .wind)
        windSpeed = wind.speed
        windDirection = wind.deg
    }
}

func getWeatherCondition(coordinates: CLLocationCoordinate2D, apiKey: String)async throws -> WeatherCondition{
    let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.latitude)&appid=\(apiKey)"
    guard let url = URL(string: endpoint) else { throw Error.invalidURL }
    let (data, responce) = try await URLSession.shared.data(from: url)
    
    guard let response = responce as? HTTPURLResponse, response.statusCode == 200 else { throw Error.invalidData }
    let decoder = JSONDecoder()
    let weatherCondition = try decoder.decode(WeatherCondition.self, from: data)
    return weatherCondition
}

enum Error: Swift.Error {
    case invalidURL
    case invalidData
}

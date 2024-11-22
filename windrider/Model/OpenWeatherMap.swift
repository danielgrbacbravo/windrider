//  windrider
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import Foundation
import CoreLocation
import SwiftData

// MARK: - OpenWeatherMapResponse

public struct OpenWeatherMapResponse: Codable {
    struct Coord: Codable {
        let lon: Double
        let lat: Double
        
        enum CodingKeys: String, CodingKey {
            case lon
            case lat
        }
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case main
            case description
            case icon
        }
    }
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
        
        enum CodingKeys: String, CodingKey {
            case speed
            case deg
        }
    }
    
    struct Clouds: Codable {
        let all: Int
        
        enum CodingKeys: String, CodingKey {
            case all
        }
    }
    
    struct Sys: Codable {
        let type: Int
        let id: Int
        let country: String
        let sunrise: Int
        let sunset: Int
        
        enum CodingKeys: String, CodingKey {
            case type
            case id
            case country
            case sunrise
            case sunset
        }
    }
    
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
    
    enum CodingKeys: String, CodingKey {
        case coord
        case weather
        case main
        case visibility
        case wind
        case clouds
        case dt
        case sys
        case timezone
        case id
        case name
        case cod
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coord = try container.decode(Coord.self, forKey: .coord)
        weather = try container.decode([Weather].self, forKey: .weather)
        main = try container.decode(Main.self, forKey: .main)
        visibility = try container.decode(Int.self, forKey: .visibility)
        wind = try container.decode(Wind.self, forKey: .wind)
        clouds = try container.decode(Clouds.self, forKey: .clouds)
        dt = try container.decode(Int.self, forKey: .dt)
        sys = try container.decode(Sys.self, forKey: .sys)
        timezone = try container.decode(Int.self, forKey: .timezone)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        cod = try container.decode(Int.self, forKey: .cod)
    }
    
   public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coord, forKey: .coord)
        try container.encode(weather, forKey: .weather)
        try container.encode(main, forKey: .main)
        try container.encode(visibility, forKey: .visibility)
        try container.encode(wind, forKey: .wind)
        try container.encode(clouds, forKey: .clouds)
        try container.encode(dt, forKey: .dt)
        try container.encode(sys, forKey: .sys)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(cod, forKey: .cod)
    }
    
}

public class OpenWeatherMapAPI{
    var openWeatherMapAPIKey: String = "" // You should place your actual API key here
    
    init(openWeatherMapAPIKey: String) {
        self.openWeatherMapAPIKey = openWeatherMapAPIKey
    }
    
    //MARK: - Fetch Weather Condition
    
    // will be deprecated in the future
    func fetchAsyncWeatherConditionAtCoordinate(coordinate: Coordinate) async throws -> OpenWeatherMapResponse {
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(openWeatherMapAPIKey)"
        
        guard let url = URL(string: endpoint) else {
            throw OpenWeatherMapAPIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(OpenWeatherMapResponse.self, from: data)
            return response
        } catch {
            throw OpenWeatherMapAPIError.invalidData
        }
    }
    
        // will be deprecated in the future
        func fetchWeatherConditionAtCoordinate(coordinate: Coordinate, completion: @escaping (Result<OpenWeatherMapResponse, Error>) -> Void) {
            let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(openWeatherMapAPIKey)"
            
            guard let url = URL(string: endpoint) else {
                completion(.failure(OpenWeatherMapAPIError.invalidURL))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(OpenWeatherMapAPIError.invalidData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OpenWeatherMapResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(OpenWeatherMapAPIError.invalidData))
                }
            }
            
            task.resume()
        }
    
    //MARK: - New Fetch Methods
    
    /// Fetches the weather conditions for a given coordinate
    /// - Parameters:
    ///  - coordinate: The coordinate for which to fetch the weather conditions
    ///  - completion: The completion handler to call when the request is complete
    ///  - result: The result of the request
        func fetchWeatherConditions(for coordinate: CLLocationCoordinate2D, completion: @escaping (Result<OpenWeatherMapResponse, Error>) -> Void) {
            let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(openWeatherMapAPIKey)"
            
            guard let url = URL(string: endpoint) else {
                completion(.failure(OpenWeatherMapAPIError.invalidURL))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(OpenWeatherMapAPIError.invalidData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OpenWeatherMapResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(OpenWeatherMapAPIError.invalidData))
                }
            }
            
            task.resume()
        }

    /// Fetches the weather conditions for a given coordinate
    ///
    /// - Parameters:
    ///  - coordinate: The coordinate for which to fetch the weather conditions
    ///  - returns: The result of the request
    func fetchWeatherConditionsAsync(for coordinate: CLLocationCoordinate2D) async throws -> OpenWeatherMapResponse{
        // Create the endpoint URL
        let endpoint = endpointURL(for: coordinate)
            
        guard let url = endpoint else {
            throw OpenWeatherMapAPIError.invalidURL
        }
        // Make the request and decode the response
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(OpenWeatherMapResponse.self, from: data)
            return response
        } catch {
            throw OpenWeatherMapAPIError.invalidData
        }
        
    }

    private func endpointURL(for coordinate: CLLocationCoordinate2D) -> URL? {
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(openWeatherMapAPIKey)"
        return URL(string: endpoint)
    }

    
    enum OpenWeatherMapAPIError: Error {
        case invalidURL
        case invalidData
    }
}

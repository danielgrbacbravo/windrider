//
//  OpenWeatherMapDebugView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 03/03/2024.
//

import SwiftUI
import CoreLocation

struct OpenWeatherMapDebugView: View {
    @EnvironmentObject var openWeatherMapAPI: OpenWeatherMapAPI
    @EnvironmentObject var route: Route
     @State var response: OpenWeatherMapResponse?
    var latitude: Double = 53.22207
    var longitude: Double = 6.53912
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("OpenWeatherMap API Settings")) {
                    Text("openWeatherMapAPIKey: \(openWeatherMapAPI.openWeatherMapAPIKey)")
                }
                
                if let response = response {
                    Section(header: Text("Weather Data")) {
                        Text("Location: \(response.name), \(response.sys.country)")
                        Text("Coordinates: \(response.coord.lat), \(response.coord.lon)")
                        Text("Temperature: \(response.main.temp)°")
                        Text("Feels Like: \(response.main.feelsLike)°")
                        Text("Min Temp: \(response.main.tempMin)°, Max Temp: \(response.main.tempMax)°")
                        Text("Pressure: \(response.main.pressure) hPa")
                        Text("Humidity: \(response.main.humidity)%")
                        Text("Visibility: \(response.visibility)m")
                        ForEach(response.weather, id: \.id) { weather in
                            Text("Weather: \(weather.main) - \(weather.description)")
                        }
                        Text("Wind Speed: \(response.wind.speed)m/s, Direction: \(response.wind.deg)°")
                        Text("Cloudiness: \(response.clouds.all)%")
                        Text("Sunrise: \(Date(timeIntervalSince1970: TimeInterval(response.sys.sunrise)), formatter: dateFormatter)")
                        Text("Sunset: \(Date(timeIntervalSince1970: TimeInterval(response.sys.sunset)), formatter: dateFormatter)")
                    }
                    Section(header: Text("test Route")){
                        Button(action: {
                            
                        }) {
                            Text("fetch and populate data")
                        }
                        if let windData = route.coordinateWindData{
                            
                            ForEach(windData,  id: \.self) { datum in
                                Section(header: Text("Calculated \(datum.hashValue)")){
                                    Text("relative Wind Direction: \(datum.relativeWindDirection)")
                                    Text("headwind Percentage \(datum.headwindPercentage)%")
                                    Text("tailwaid Percentage \(datum.tailwindPercentage)%")
                                    Text("crosswind Percentage \(datum.crosswindPercentage)%")
                                }
                            }
                        }
                    }
                }
            }.navigationTitle("OpenWeatherMap API")
                .task {
                    do {
                        response = try await openWeatherMapAPI.fetchWeatherConditionAtCoordinate(coordinate:  CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    } catch {
                        print("Error fetching weather condition: \(error)")
                    }
                }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }
}

struct OpenWeatherMapDebugView_Previews: PreviewProvider {
    static var previews: some View {
        OpenWeatherMapDebugView().environmentObject(OpenWeatherMapAPI(openWeatherMapAPIKey: "22ab22ed87d7cc4edae06caa75c7f449"))
    }
}

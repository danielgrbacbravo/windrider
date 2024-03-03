//
//  WeatherAPIDebugView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 02/03/2024.
//

import SwiftUI
import CoreLocation
struct WeatherAPIDebugView: View {
    @Binding var weatherAPIKey: String
    @State var longitude = ""
    @State var latitude = ""
    @State var currentWeatherConditions: windCondition?
    var body: some View {
        NavigationStack{
            Form {
                Section(header: Text("Weather API Settings")) {
                    Text(weatherAPIKey)
                }
                Section(header: Text("basic API call")){
                    TextField("Latitude", text: $latitude)
                    TextField("Longitude", text: $longitude)
                    Button("Get Wind Conditions") {
                        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
                        Task {
                            do{
                                currentWeatherConditions = try await fetchWindConditionAtCoordinate(coordinate: coordinate, apiKey: weatherAPIKey)
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }
                    
                    if let currentWeatherConditions = currentWeatherConditions {
                        Section(header: Text("Current Weather Conditions")) {
                            Text("Wind Speed: \(currentWeatherConditions.windSpeed) m/s").foregroundStyle(.red)
                            Text("Wind Direction: \(currentWeatherConditions.windDirection) degrees").foregroundStyle(.red)
                        }
                    }
                }
                
            }.navigationTitle("API Debugger")
                .tint(.red)
        }
    }
}

struct WeatherAPIDebugView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var weatherAPIKey = "22ab22ed87d7cc4edae06caa75c7f449"

        var body: some View {
            WeatherAPIDebugView(weatherAPIKey: $weatherAPIKey)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}

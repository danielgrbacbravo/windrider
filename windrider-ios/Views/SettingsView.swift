//
//  SettingsView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 02/03/2024.
//

//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var openWeatherMapAPI: OpenWeatherMapAPI
    var body: some View {
        NavigationStack{
            Form {
                Section(header: Text("Weather API Settings")) {
                    TextField("WeatherAPIKey", text: $openWeatherMapAPI.openWeatherMapAPIKey)
                }.navigationTitle("Settings")
            }
        }
    }
}
    
    
struct SettingsView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var weatherAPIKey = "22ab22ed87d7cc4edae06caa75c7f449"

        var body: some View {
            SettingsView().environmentObject(OpenWeatherMapAPI(openWeatherMapAPIKey: weatherAPIKey))
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}

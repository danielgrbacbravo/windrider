//
//  SettingsView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 02/03/2024.
//

//


import SwiftUI

struct SettingsView: View {
    @Binding var weatherAPIKey: String
    var body: some View {
        NavigationStack{
            Form {
                Section(header: Text("Weather API Settings")) {
                    TextField("WeatherAPIKey", text: $weatherAPIKey)
                }.navigationTitle("Settings")
            }
        }
    }
}
    
    
struct SettingsView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var weatherAPIKey = "22ab22ed87d7cc4edae06caa75c7f449"

        var body: some View {
            SettingsView(weatherAPIKey: $weatherAPIKey)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}

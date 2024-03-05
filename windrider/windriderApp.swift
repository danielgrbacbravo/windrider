//
//  windriderApp.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import SwiftUI
import SwiftData

@main
struct windriderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
        .modelContainer(for: [BikeRoute.self])
        .modelContainer(for: OpenWeatherMapAPI.self)
    }
}

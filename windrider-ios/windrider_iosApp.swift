//
//  windrider_iosApp.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//

import SwiftUI
import SwiftData

@main
struct WindRider_App: App {
    let exampleCondition = WindCondition(direction: "NW", speed: 10, headwindPercentage: 12)
    var body: some Scene {
        WindowGroup {
            ContentView(condition:exampleCondition)
        }
    }
}


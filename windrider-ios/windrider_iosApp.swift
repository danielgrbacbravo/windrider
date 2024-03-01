//
//  windrider_iosApp.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//

import SwiftUI
import SwiftData
import CoreLocation

@main
struct WindRider_App: App {
    let randomRoute = Route(name: "route to University",points: [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                                     CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                                     CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                                     CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                                     CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                                     CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)
                                    ])
    var body: some Scene {
        WindowGroup {
            ContentView(route: randomRoute)
        }
    }
}


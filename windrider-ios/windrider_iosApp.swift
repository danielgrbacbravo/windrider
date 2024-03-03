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
    
    let randomRouteCoordinates = [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                                  CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                                  CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                                  CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                                  CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                                  CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)]
    
    @StateObject var openWeatherMapAPI = OpenWeatherMapAPI(openWeatherMapAPIKey: "")
    
    var body: some Scene {
       @StateObject var currentSelectedRoute = Route(name: "Test Route", coordinates: randomRouteCoordinates)
        
        return WindowGroup {
            ContentView()
                .environmentObject(openWeatherMapAPI)
                .environmentObject(currentSelectedRoute)
        }
    }
}



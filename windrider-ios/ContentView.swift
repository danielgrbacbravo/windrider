//
//  ContentView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//

import Foundation
import SwiftUI

struct ContentView: View {
    var condition: WindCondition
    let randomRoute = Route(points: [RoutePoint(latitude: 53.22240, longitude: 6.53929, direction: 0, timestamp: Date()), RoutePoint(latitude: 53.22240, longitude: 6.53929, direction: 0, timestamp: Date())])
    var body: some View {
        ZStack{
            RouteMapView(route: randomRoute)
        }
    }
}

// PreviewProvider to see the design in Xcode's Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating an example condition to use in our preview
        let exampleCondition = WindCondition(direction: "NW", speed: 15.5, headwindPercentage: 60)
        // Returning the view configured with the example condition
        ContentView(condition: exampleCondition)
    }
}

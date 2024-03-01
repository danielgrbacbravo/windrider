//
//  ContentView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//

import Foundation
import SwiftUI
import CoreLocation

struct ContentView: View {
    var route: Route
    var body: some View {
        VStack{
            RouteMapView(route: route).saturation(0.5).blur(radius: 2)
                ConditionPreviewView(route: route).clipShape(RoundedRectangle(cornerRadius: 15))
            }.frame(maxWidth: .infinity)
        }
    
}
let randomRoute = Route(name: "Route To University", points: [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                                 CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                                 CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                                 CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                                 CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                                 CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)
                                ])
// PreviewProvider to see the design in Xcode's Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        // Creating an example condition to use in our preview
        ContentView(route: randomRoute)
    }
}

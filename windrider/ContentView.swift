//
//  ContentView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routes: [BikeRoute]
    var body: some View {
        NavigationStack{
            List(routes, id: \.bikeRouteId){ route in
                Text(route.name!)
                Map{
                    MapPolyline(coordinates: route.getAndConvertCoordinates())
                }
                .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
            }
        }
        .navigationTitle("WindRider")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("populate Sample Data") {
                    let sampleRoute = generateSampleRoute()
                    modelContext.insert(sampleRoute)
                }
            }
            
        }
    }
}

func generateSampleRoute() -> BikeRoute{
   let points = [Coordinate(latitude: 53.22163,longitude: 6.54162),
                 Coordinate(latitude: 53.22188,longitude: 6.54115),
                 Coordinate(latitude: 53.22214,longitude: 6.54089)]
   let route = BikeRoute(name: "To University", coordinates:points)
   return route
}

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
    @State private var selectedRoute: BikeRoute?
    @State var isRouteSelectionViewPresented = false

    var body: some View {
        ZStack {
            // Map view as the base layer
            Map {
                if let routeCoordinates = selectedRoute?.getAndConvertCoordinates() {
                    MapPolyline(coordinates: routeCoordinates, contourStyle: .geodesic).stroke(lineWidth: 3).stroke(Color.purple)
                }
            }

            // Conditional rendering of RouteConditionPreviewView on top of the Map
            if selectedRoute != nil {
                
                VStack{
                    RouteConditionPreviewView(route: $selectedRoute)
                        .padding(.vertical, 30)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .zIndex(1) // Ensure it stays on top
                        .ignoresSafeArea()
                    Spacer()
                }
    
            }

            // Buttons positioned at the bottom or another place
            VStack {
                Spacer() // Pushes the content to the bottom
                HStack {
                    
                    Button {
                        let route = generateSampleRoute()
                        modelContext.insert(route)
                    } label: {
                        Image(systemName: "plus")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())

                    }

                    Button {
                        isRouteSelectionViewPresented = true
                    } label: {
                        Image(systemName: "list.bullet")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                    }.sheet(isPresented: $isRouteSelectionViewPresented, content: {
                        RouteSelectionView(selectedRoute: $selectedRoute, isRouteSelectionViewPresented: $isRouteSelectionViewPresented)
                    })
                    
                    
                    Button {
                        selectedRoute?.fetchAndPopulateBikeRouteConditions(openWeatherMapAPI: OpenWeatherMapAPI(openWeatherMapAPIKey: "22ab22ed87d7cc4edae06caa75c7f449"))
                    } label: {
                        Image(systemName: "cloud.sun")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                    }

                    
                    Button {
                        for route in routes {
                            modelContext.delete(route)
                        }
                    } label: {
                        Image(systemName: "trash")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                    }
                }
            }
            .padding() // Add some padding around the HStack for better spacing
        }
    }
}

private func generateSampleRoute() -> BikeRoute {
    let points = [Coordinate(latitude: 53.22163, longitude: 6.54162),
                  Coordinate(latitude: 53.22176, longitude: 6.54138),
                  Coordinate(latitude: 53.22187, longitude: 6.54118),
                  Coordinate(latitude: 53.22201, longitude: 6.54101),
                  Coordinate(latitude: 53.22280, longitude: 6.54033)
                ]
    
    
    let route = BikeRoute(name: "To University", coordinates: points)
    return route
}
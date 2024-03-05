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
    
    @EnvironmentObject var openWeatherMapAPI: OpenWeatherMapAPI
    @EnvironmentObject var route: Route
    
    @State private var showingSettings = false
    @State private var showingDebugMenu = false
    @State private var showingRouteSettings = false
    @State var selectedCoordinate: Int?
    
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            RouteMapView(route: route)
                .edgesIgnoringSafeArea(.all) // Make the map view fill the entire screen

            HStack{
                Button(action: {
                    self.showingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                        .padding()
                        .foregroundColor(.secondary)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                        .padding([.top, .trailing]) // Add padding to top and trailing to position the button
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView().environmentObject(openWeatherMapAPI)
                }
                Button(action: {
                    self.showingDebugMenu.toggle()
                }) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .padding()
                        .foregroundColor(.red)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                        .padding([.top, .trailing]) // Add padding to top and leading to position the button
                }
                .sheet(isPresented: $showingDebugMenu) {
                    OpenWeatherMapDebugView().environmentObject(openWeatherMapAPI)
                }
                Button(action: {
                    self.showingRouteSettings.toggle()
                }) {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                        .padding()
                        .foregroundColor(.secondary)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                        .padding([.top, .trailing]) // Add padding to top and trailing to position the button
                }.sheet(isPresented: $showingRouteSettings) {
                    RouteDebugView(rawSelectedCoordinate: $selectedCoordinate).environmentObject(route)
                }
                
                
                
            }
            
           
            
        }
    }
}


// Assuming CoreLocation and Foundation have been imported to use CLLocationCoordinate2D and UUID

let randomRouteCoordinates = [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                              CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                              CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                              CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                              CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                              CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)]

var randomRoute = Route(name: "Route To University", coordinates: randomRouteCoordinates)

// Calculate and assign coordinate angles after the Route has been initialized

// PreviewProvider to see the design in Xcode's Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(randomRoute)
    }
}

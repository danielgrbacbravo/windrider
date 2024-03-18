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

    @Query private var paths: [CyclingPath]
    @State private var selectedRoute: BikeRoute?
    @State private var selectedPath: CyclingPath?

    // Weather impact analysis
    @State private var weatherImpact: PathWeatherImpact?
    @State private var coordinateWeatherImpact: [CoordinateWeatherImpact]?
    @State var isRouteSelectionViewPresented = false
    @State var isRouteRecorderViewPresented = false
    @State var isFetching = false

    @State var polylineSegements: [PolylineSegement]?

    @State var cyclingPathRecorder: CyclingPathRecorder = CyclingPathRecorder()

    var body: some View {
        ZStack {
            // Map view as the base layer
            Map {
                if let polylineSegements = polylineSegements {
                    ForEach(Array(polylineSegements.enumerated()), id: \.offset) { index , object in
                        MapPolyline(coordinates: object.coordinateArray, contourStyle:
                                .geodesic).stroke(lineWidth: 3).stroke(object.color)
                    }
                }




//                if let routeCoordinates = selectedPath?.getCoordinates() {
//                    MapPolyline(coordinates: routeCoordinates, contourStyle: .geodesic).stroke(lineWidth: 3).stroke(Color.purple)
//                }
            }

            // Conditional rendering of RouteConditionPreviewView on top of the Map


                VStack{
                    RouteConditionPreviewView(selectedPath: $selectedPath,
                                              weatherImpact: $weatherImpact,
                                              coordinateWeatherImpact: $coordinateWeatherImpact,
                                              isFetching: $isFetching)
                        .padding(.vertical, 30)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .zIndex(1) // Ensure it stays on top
                        .ignoresSafeArea()
                    Spacer()
                }



            // Buttons positioned at the bottom or another place
            VStack {
                Spacer() // Pushes the content to the bottom
                HStack {

                    Button {
                        let path = generateSamplePath()
                        modelContext.insert(path)
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
                        RouteSelectionView(selectedPath: $selectedPath, isRouteSelectionViewPresented: $isRouteSelectionViewPresented)
                    })


                    Button {

                        guard let selectedPath = selectedPath else { return}

                        let engine = WeatherImpactAnalysisEngine()

                        engine.analyseImpact(for: selectedPath, with: OpenWeatherMapAPI(openWeatherMapAPIKey: "22ab22ed87d7cc4edae06caa75c7f449")) { result in
                            switch result{
                            case .success(let response):
                                coordinateWeatherImpact = response.0
                                weatherImpact = response.1

                                // create polyline segments
                                polylineSegements = WeatherImpactAnalysisEngine.constructWeatherImpactPolyline(coordinateWeatherImpacts: coordinateWeatherImpact!, cyclingPath: selectedPath)

                            case .failure(_):
                                return
                            }
                        }

                    } label: {
                        Image(systemName: "cloud.sun")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())

                    }




                    Button {
                        for path in paths {
                            modelContext.delete(path)
                        }
                    } label: {
                        Image(systemName: "trash")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                    }

                    Button {
                        isRouteRecorderViewPresented = true
                    } label: {
                        Image(systemName: "record.circle")
                                                .padding()
                                                .foregroundColor(.red)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                    }.sheet(isPresented: $isRouteRecorderViewPresented, content: {
						PathRecorderView(isPathRecorderViewPresented: $isRouteRecorderViewPresented, cyclingPathRecorder: $cyclingPathRecorder)
                    })



                }
            }
            .padding() // Add some padding around the HStack for better spacing
        }
    }
}

private func generateSamplePath() -> CyclingPath {
    let points = [CLLocationCoordinate2D(latitude: 53.22210, longitude: 6.53897),
                  CLLocationCoordinate2D(latitude: 53.22173, longitude: 6.53933),
                  CLLocationCoordinate2D(latitude: 53.22135, longitude: 6.53977),
                  CLLocationCoordinate2D(latitude: 53.22167, longitude: 6.54063)

                ]
    let route = CyclingPath(name: "To University", coordinates: points)
    return route
}

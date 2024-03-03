//
//  RouteDebugView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 03/03/2024.
//

import SwiftUI
import MapKit

struct RouteDebugView: View {
    @EnvironmentObject var route: Route // Assuming Route conforms to ObservableObject
    
    // For input fields to add wind data
    @State private var windSpeed: Double = 0
    @State private var windDirection: Double = 0
    @State private var coordinateAngle: Double = 0
    
    var body: some View {
        
        NavigationStack{
            List{
                Section(header: Text("Route ID")) {
                    Text(route.routeId?.uuidString ?? "N/A")
                }
                Section(header: Text("Route Name")) {
                    Text(route.name ?? "Unnamed")
                }
                
                Section(header: Text("Average Coordinate")) {
                    Text("\(route.averageCoordinate.latitude), \(route.averageCoordinate.longitude)")
                }
                
                Section(header: Text("Coordinates")) {
                    if let coords = route.coordinates {
                        ForEach(coords.indices, id: \.self) { index in
                            Text("\(coords[index].latitude), \(coords[index].longitude)")
                        }
                    }
                }
                
                Section(header: Text("Angles")) {
                    if let angles = route.coordinateAngles {
                        ForEach(angles.indices, id: \.self) { index in
                            Text("\(angles[index])")
                        }
                    }
                }
                
                // description
                Text("the route object contains coordinateWindData objects that are empty by default. by giving windSpeed and windDirection we populate those points with this data as well as other calculations it makes during init (relativeAngle, headwindProbablity, TailwindProbability and CrosswindProbablity ").font(.caption)
                
                Section(header: Text("Add Wind Data")) {
                    HStack {
                        TextField("Wind Speed", value: $windSpeed, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Wind Direction", value: $windDirection, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Button(action: {
                        
                        
                        let newWindData = CoordinateWindData(windSpeed: windSpeed, windDirection: windDirection, coordinateAngle: coordinateAngle)
                        route.setWindData(windData: [newWindData]) // Assumes setWindData accepts an array
                        
                        
                 
                    }) {
                        Text("Add Wind Data")
                    }
                    
                    if let windData = route.coordinateWindData {
                        ForEach(windData, id: \.self) { data in
                            VStack(alignment: .leading) {
                                Text("Wind Speed: \(data.windSpeed)")
                                Text("Wind Direction: \(data.windDirection)")
                                Text("relativeDirection: \(data.relativeWindDirection)")
                                Text("headwindProbablity: \(data.headwindPercentage)")
                                Text("TailwindProbability: \(data.tailwindPercentage)")
                                Text("CrosswindProbablity: \(data.crosswindPercentage)")
                            }
                        }
                    }
                }
                
                
            }.navigationTitle("Route Class Tester")
        }
    }
}

//preview

struct RouteDebugView_Previews: PreviewProvider {
   
    static var previews: some View {
        let randomRouteCoordinates = [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                                      CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                                      CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                                      CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                                      CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                                      CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)]
        let randomRoute = Route(name: "Test Route", coordinates: randomRouteCoordinates)
        RouteDebugView().environmentObject(randomRoute)
    }
}

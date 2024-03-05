//
//  RouteDebugView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 03/03/2024.
//

import SwiftUI
import MapKit
import Charts

struct RouteDebugView: View {
    @EnvironmentObject var route: Route // Assuming Route conforms to ObservableObject

    // For input fields to add wind data
    @State private var windSpeed: Double? = 0
    @State private var windDirection: Double? = 0
    
    @State private var coordinateAngle: Double = 0
    
     @State var tempWindSpeed: String = ""
    @State var tempWindDirection: String = ""

    
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
                    
                    TextField("wind Speed", text: $tempWindSpeed)
                    TextField("wind Direction", text: $tempWindDirection)
                    
                    
                    Button(action: {
                        if let windSpeed = windSpeed, let windDirection = windDirection {
                            var windDataArray: [CoordinateWindData] = []
                            
                            if let coordinateAngles = route.coordinateAngles {
                                for (index, angle) in coordinateAngles.enumerated() {
                                    var windData = CoordinateWindData(index: index, windSpeed: windSpeed, windDirection: windDirection, coordinateAngle: angle)
                                    windData.updatePercentages()
                                    windDataArray.append(windData)
                                    
                                }
                            }
                            
                            route.setWindData(windData: windDataArray)
                                }
                        
                    }) {
                        Text("populate route.coordinateWindData")
                    }
                }
                    if let windData = route.coordinateWindData{
                        
                        ForEach(windData,  id: \.self) { datum in
                            Section(header: Text("Calculated \(datum.hashValue)")){
                                Text("relative Wind Direction: \(datum.relativeWindDirection)")
                                Text("headwind Percentage \(datum.headwindPercentage)%")
                                Text("tailwaid Percentage \(datum.tailwindPercentage)%")
                                Text("crosswind Percentage \(datum.crosswindPercentage)%")
                            }
                        }
                    }
                
                
                // test charts
                
                if let windData = route.coordinateWindData{
                    Chart{
                        ForEach(windData,  id: \.index) { datum in
                            LineMark(
                                x: .value("Current coord", datum.index),
                                y: .value("Percentage", datum.headwindPercentage))
                        } .interpolationMethod(.catmullRom)
                        
                        
                    }.padding()
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
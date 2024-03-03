//
//  ConditionPreviewView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//


import SwiftUI
import CoreLocation
import MapKit

struct ConditionPreviewView: View {
    var route: Route
    var unWrappedName: String {
        route.name ?? "No Name"
    }
    
    var condition: String = "tailwinds"
    var body: some View {
        VStack{
            HStack{
                Text(unWrappedName).font(.title).bold()
            }.frame(maxWidth: .infinity, alignment: .leading)
            // wind direction
            HStack{
                Text("looks like mostly ").font(.subheadline).foregroundStyle(.gray) +
                Text(condition).bold().font(.subheadline).foregroundStyle(.blue) +
                Text(" today").font(.subheadline).foregroundColor(.gray) // todays condition
                Image(systemName:"wind").foregroundStyle(.blue)
            }.frame(maxWidth: .infinity, alignment: .leading)
            // wind speed
            HStack{
                Text("with speeds of ").font(.subheadline).foregroundStyle(.gray) +
                Text("10").bold().font(.subheadline).foregroundStyle(.blue) +
                Text(" km/h").font(.subheadline).foregroundStyle(.gray) // wind speed
                ProgressView(value: 0.5, total: 1.0).progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }.frame(maxWidth: .infinity, alignment: .leading)
            // temperature
            HStack{
                Text("and a temperature of ").font(.subheadline).foregroundStyle(.gray) +
                Text("15").bold().font(.subheadline).foregroundStyle(.blue) +
                Text("°C").font(.subheadline).foregroundStyle(.gray) // temperature
                Image(systemName:"thermometer").foregroundStyle(.blue)
            }.frame(maxWidth: .infinity, alignment: .leading)
            //condition
            HStack{
                Text("with a chance of ").font(.subheadline).foregroundStyle(.gray) +
                Text("0").bold().font(.subheadline).foregroundStyle(.blue) +
                Text("% precipitation").font(.subheadline).foregroundStyle(.gray) // precipitation
                Image(systemName:"cloud.drizzle").foregroundStyle(.blue)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            
        }   .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}




// PreviewProvider to see the design in Xcode's Canvas
struct ConditionPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating an example condition to use in our preview
        let randomRouteCoordinates = [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                                      CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                                      CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                                      CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                                      CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                                      CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)]

        let randomRoute = Route(name: "Route To University", coordinates: randomRouteCoordinates)
        // Returning the view configured with the example condition
        ConditionPreviewView(route: randomRoute)
    }
}

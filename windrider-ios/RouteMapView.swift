//
//  RouteMapView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 01/03/2024.
//

import SwiftUI
import MapKit

func calculateRegion(boundingBox: [RoutePoint]) -> MKCoordinateRegion {
    let minLat = boundingBox[0].latitude
    let maxLat = boundingBox[1].latitude
    let minLon = boundingBox[0].longitude
    let maxLon = boundingBox[1].longitude
    
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.1, longitudeDelta: (maxLon - minLon) * 1.1)
    
    return MKCoordinateRegion(center: center, span: span)
}




struct RouteMapView: View {
    var route: Route
    @State private var region: MKCoordinateRegion

    init(route: Route) {
        self.route = route
        let boundingBox = route.caluateBoundingBox(route: route) // Assuming this is a correct method call
        self._region = State(initialValue: calculateRegion(boundingBox: boundingBox))
    }

    var body: some View {
        ZStack{
            Map(){
                
            }
            .ignoresSafeArea()
       
        }
    }
}


struct RouteMapView_Previews: PreviewProvider {
    static func createRandomRoute() -> Route {
        var points = [RoutePoint]()
        for _ in 0...100 {
            points.append(RoutePoint(latitude: Double.random(in: 53.0...54.0), longitude: Double.random(in: 6.0...7.0), direction: Double.random(in: 0...360), timestamp: Date()))
        }
        return Route(points: points)
    }
    
    static var previews: some View {
        // Now this call is valid because createRandomRoute is a static method
        let randomRoute = createRandomRoute()
        
        RouteMapView(route: randomRoute)
    }
}

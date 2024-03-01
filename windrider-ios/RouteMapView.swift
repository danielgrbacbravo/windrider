//
//  RouteMapView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 01/03/2024.
//

import SwiftUI
import CoreLocation
import MapKit


struct RouteMapView: View {
    var route: Route
    
    var body: some View {
        ZStack{
            Map{
                MapPolyline(coordinates: route.points, contourStyle: .geodesic).stroke(lineWidth: 3).stroke(Color.purple)
            }
            .ignoresSafeArea()
       
        }
    }
}

let randomRoute = Route(points: [CLLocationCoordinate2D(latitude: 53.22207, longitude: 6.53912),
                                 CLLocationCoordinate2D(latitude: 53.22139, longitude: 6.53978),
                                 CLLocationCoordinate2D(latitude: 53.22170, longitude: 6.54061),
                                 CLLocationCoordinate2D(latitude: 53.22137, longitude: 6.54112),
                                 CLLocationCoordinate2D(latitude: 53.22163, longitude: 6.54163),
                                 CLLocationCoordinate2D(latitude: 53.22187, longitude: 6.54117)
                                ])
struct RouteMapView_Previews: PreviewProvider {
    static var previews: some View {
        RouteMapView(route: randomRoute)
    }
}

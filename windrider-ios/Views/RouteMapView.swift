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

struct RouteMapView_Previews: PreviewProvider {
    static var previews: some View {
        RouteMapView(route: randomRoute)
    }
}

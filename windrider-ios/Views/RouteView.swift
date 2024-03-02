//
//  RouteView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 02/03/2024.
//

import SwiftUI
import MapKit


struct RouteView: View {
    var route: Route
    var body: some View {
        ZStack{
            Map{
                MapPolyline(coordinates: route.points, contourStyle: .geodesic).stroke(lineWidth: 3).stroke(Color.purple)
            }
            
            RouteInfoView()
                .edgesIgnoringSafeArea(.all)
        }
        
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView(route: randomRoute)
    }
}


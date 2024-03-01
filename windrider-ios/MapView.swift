//
//  MapView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.22240, longitude: 6.53929), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        ZStack{
            Map()
            .ignoresSafeArea()    
        }
    }
}

// PreviewProvider to see the design in Xcode's Canvas
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
    
    
}

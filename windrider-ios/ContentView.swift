//
//  ContentView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//

import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            RouteMapView(route: randomRoute)
        }
    }
}

// PreviewProvider to see the design in Xcode's Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating an example condition to use in our preview
        ContentView()
    }
}

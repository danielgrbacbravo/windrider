//
//  ConditionPreviewView.swift
//  windrider-ios
//
//  Created by Daniel Grbac Bravo on 29/02/2024.
//


import SwiftUI

struct ConditionPreviewView: View {
    var condition: WindCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cycling Conditions")
                .font(.headline)
            Text("Speed: \(condition.speed, specifier: "%.2f") km/h")
            Text("Headwind: \(condition.headwindPercentage, specifier: "%.0f")% of ride")
        }.padding()
    }
}

// PreviewProvider to see the design in Xcode's Canvas
struct ConditionPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating an example condition to use in our preview
        let exampleCondition = WindCondition(direction: "NW", speed: 15.5, headwindPercentage: 60)
        
        // Returning the view configured with the example condition
        ConditionPreviewView(condition: exampleCondition)
    }
}

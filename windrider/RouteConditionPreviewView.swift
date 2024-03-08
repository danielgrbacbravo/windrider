//
//  RouteConditionPreviewView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 07/03/2024.
//

import SwiftUI
import SwiftData

struct RouteConditionPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routes: [BikeRoute]
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    let headwindGradient = Gradient(colors: [.black, .red])
    let crosswindGradient = Gradient(colors: [.black, .orange])
    let tailwindGradient = Gradient(colors: [.black , .green])
    let windSpeedGradient = Gradient(colors: [.green, .yellow, .orange, .red])
    
    var body: some View {
        VStack{
            HStack{
                Text("Route Condition for \(routes.first?.name ?? "")")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundStyle(.primary)
            }
            
            
            
            HStack{
                
                    Gauge(value: Double(routes.first?.bikeRouteCondition?.totalCrosswindPercentage ?? 0)/100){
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                        } currentValueLabel: {
                            HStack{
                                Text("\(routes.first?.bikeRouteCondition?.totalCrosswindPercentage ?? 0)%").bold()
                            }
                            
                        }
                        .gaugeStyle(.accessoryCircular)
                        .tint(crosswindGradient)
                
               
                
                Gauge(value: Double(routes.first?.bikeRouteCondition?.totalTailwindPercentage ?? 0)/100){
                    Image(systemName: "arrow.right.to.line")
                } currentValueLabel: {
                    HStack{
                        Text("\(routes.first?.bikeRouteCondition?.totalTailwindPercentage ?? 0)%").bold()
                    }
                    
                }
                .gaugeStyle(.accessoryCircular)
                .tint(tailwindGradient)
                
                Gauge(value: Double(routes.first?.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
                    Image(systemName: "arrow.left.to.line")
                } currentValueLabel: {
                    HStack{
                        Text("\(routes.first?.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").bold()
                    }
                    
                }
                .gaugeStyle(.accessoryCircular)
                .tint(headwindGradient)
            }
            Gauge(value: Double(routes.first?.bikeRouteCondition?.windSpeed ?? 0)/100){
                Image(systemName: "arrow.left.to.line")
            } currentValueLabel: {
                HStack{
                    Text("\(routes.first?.bikeRouteCondition?.windSpeed ?? 0) m\\s").bold()
                }
                
            }
            .gaugeStyle(.accessoryLinear)
            .tint(windSpeedGradient)
        }
    }
}


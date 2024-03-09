//
//  RouteConditionPreviewView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 07/03/2024.
//

import SwiftUI

struct RouteConditionPreviewView: View {
    @Binding var selectedRoute: BikeRoute?
    @Binding  var isFetching: Bool
    @State private var fetchTimestamp: Date?
    
    
    let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
    let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
    let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
    let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
    
    var body: some View {
        if selectedRoute == nil {
            HStack{
                Image(systemName: "point.bottomleft.forward.to.arrowtriangle.uturn.scurvepath.fill")
                Text("No Route Selected")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundStyle(.primary)
            }.padding()

            
        } else {
            VStack{
                HStack{
                    Image(systemName: "bicycle")
                    Text("Route Conditions:  \(selectedRoute?.name ?? "")")
                        .font(.headline)
                        .bold()
                        .padding()
                        .foregroundStyle(.primary)
                }
                
                
                
                HStack{
                    
                    Text("Good Day to Cycle").bold()
                    Image(systemName: "bicycle.circle.fill").foregroundStyle(.green)
                    
                    Gauge(value: Double(selectedRoute?.bikeRouteCondition?.totalCrosswindPercentage ?? 0)/100){
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                            } currentValueLabel: {
                                HStack{
                                    Text("\(selectedRoute?.bikeRouteCondition?.totalCrosswindPercentage ?? 0)%").bold()
                                }
                                
                            }
                            .gaugeStyle(.accessoryCircular)
                            .tint(crosswindGradient)
                    
                   
                    
                    Gauge(value: Double(selectedRoute?.bikeRouteCondition?.totalTailwindPercentage ?? 0)/100){
                        Image(systemName: "arrow.right.to.line")
                    } currentValueLabel: {
                        HStack{
                            Text("\(selectedRoute?.bikeRouteCondition?.totalTailwindPercentage ?? 0)%").bold()
                        }
                        
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(tailwindGradient)
                    
                    Gauge(value: Double(selectedRoute?.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
                        Image(systemName: "arrow.left.to.line")
                    } currentValueLabel: {
                        HStack{
                            Text("\(selectedRoute?.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").bold()
                        }
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(headwindGradient)
                }
                Gauge(value: Double(selectedRoute?.bikeRouteCondition?.windSpeed ?? 0)/100){
                    Image(systemName: "arrow.left.to.line")
                } currentValueLabel: {
                    HStack{
                        
                            Text("with winds of \(selectedRoute?.bikeRouteCondition?.windSpeed ?? 0) m\\s").bold()
                            
                    }
                }
                .gaugeStyle(.accessoryLinear)
                .tint(windSpeedGradient)
            }.padding()
        }
    }
}


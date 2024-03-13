//
//  RouteConditionPreviewView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 07/03/2024.
//

import SwiftUI

struct RouteConditionPreviewView: View {
    @Binding var selectedPath: CyclingPath?
    @Binding var weatherImpact: PathWeatherImpact?
    @Binding  var isFetching: Bool
    @State private var fetchTimestamp: Date?
    
    
    let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
    let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
    let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
    let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
    
    var body: some View {
        if selectedPath == nil{
            HStack{
                Image(systemName: "point.bottomleft.forward.to.arrowtriangle.uturn.scurvepath.fill")
                Text("No Route Selected")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundStyle(.primary)
            }.padding()

            
        } else if weatherImpact == nil{
            HStack{
                Image(systemName: "point.bottomleft.forward.to.arrowtriangle.uturn.scurvepath.fill")
                Text("No Fetched Data")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundStyle(.primary)
            }.padding()
            
            
        }else {
            VStack{
                HStack{
                    Image(systemName: "bicycle")
                    Text("Route Conditions:  \(selectedPath?.name ?? "")")
                        .font(.headline)
                        .bold()
                        .padding()
                        .foregroundStyle(.primary)
                }
                
                
                
                HStack{
                    
                    Text("Good Day to Cycle").bold()
                    Image(systemName: "bicycle.circle.fill").foregroundStyle(.green)
                    
                    Gauge(value: Double(weatherImpact?.crosswindPercentage ?? 0)/100){
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                            } currentValueLabel: {
                                HStack{
                                    Text("\(weatherImpact?.crosswindPercentage ?? 0)%").bold()
                                }
                                
                            }
                            .gaugeStyle(.accessoryCircular)
                            .tint(crosswindGradient)
                    
                   
                    
                    Gauge(value: Double(weatherImpact?.tailwindPercentage ?? 0)/100){
                        Image(systemName: "arrow.right.to.line")
                    } currentValueLabel: {
                        HStack{
                            Text("\(weatherImpact?.tailwindPercentage ?? 0)%").bold()
                        }
                        
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(tailwindGradient)
                    
                    Gauge(value: Double(weatherImpact?.headwindPercentage ?? 0)/100){
                        Image(systemName: "arrow.left.to.line")
                    } currentValueLabel: {
                        HStack{
                            Text("\(weatherImpact?.headwindPercentage ?? 0)%").bold()
                        }
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(headwindGradient)
                }
                Gauge(value: Double(weatherImpact?.windSpeed ?? 0)/100){
                    Image(systemName: "arrow.left.to.line")
                } currentValueLabel: {
                    HStack{
                        
                            Text("with winds of \(weatherImpact?.windSpeed ?? 0) m\\s").bold()
                            
                    }
                }
                .gaugeStyle(.accessoryLinear)
                .tint(windSpeedGradient)
            }.padding()
        }
    }
}


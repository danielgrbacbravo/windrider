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
    
    
    
    @Namespace var animation
    @State private var isExpanded = false
    
    let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
    let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
    let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
    let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
    let temperatureGradient = Gradient(colors: [ .purple, .blue, .green,.red])
        
        
        var body: some View {
        if selectedPath == nil{
            HStack{
              
                Text("No Route Selected")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundStyle(.primary)
            }.padding()

            
        } else if weatherImpact == nil{
            HStack{
             
                Text("No Fetched Data")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundStyle(.primary)
            }.padding()
            
            
        }else {
            ZStack{
                if !isExpanded {
                    /// preview view
                    VStack{
                        HStack{
                            Text("\(selectedPath?.name ?? "")")
                                .font(.title)
                                .bold()
                                .padding()
                                .foregroundStyle(.primary)
                                .matchedGeometryEffect(id: "titleText", in: animation)
                        }
                        HStack{
                            
                            Gauge(value: Double(kelvinToCelsius(weatherImpact?.temperature ?? 0)), in: -20...40){
                                        Image(systemName: "thermometer.medium")
                                    } currentValueLabel: {
                                        HStack{
                                            Text("\(truncateToOneDecmialPlace(kelvinToCelsius(weatherImpact?.temperature ?? 0)))°").bold()
                                        }
                                        
                                    }
                                    .gaugeStyle(.accessoryCircular)
                                    .tint(temperatureGradient)
                                    .matchedGeometryEffect(id: "temperatureGauge", in: animation)
                            
                            
                            Gauge(value: Double(weatherImpact?.crosswindPercentage ?? 0)/100){
                                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    } currentValueLabel: {
                                        HStack{
                                            Text("\(truncateToOneDecmialPlace(weatherImpact?.crosswindPercentage ?? 0))%").bold()
                                        }
                                        
                                    }
                                    .gaugeStyle(.accessoryCircular)
                                    .tint(crosswindGradient)
                                    .matchedGeometryEffect(id: "crosswindPercentageGauge", in: animation)
                            
                           
                            
                            Gauge(value: Double(weatherImpact?.tailwindPercentage ?? 0)/100){
                                Image(systemName: "arrow.right.to.line")
                            } currentValueLabel: {
                                HStack{
                                    Text("\(truncateToOneDecmialPlace(weatherImpact?.tailwindPercentage ?? 0))%").bold()
                                }
                                
                            }
                            .gaugeStyle(.accessoryCircular)
                            .tint(tailwindGradient)
                            .matchedGeometryEffect(id: "tailwindPercentageGauge", in: animation)
                            
                            Gauge(value: Double(weatherImpact?.headwindPercentage ?? 0)/100){
                                Image(systemName: "arrow.left.to.line")
                            } currentValueLabel: {
                                HStack{
                                    Text("\(truncateToOneDecmialPlace(weatherImpact?.headwindPercentage ?? 0))%").bold()
                                }
                            }
                            .gaugeStyle(.accessoryCircular)
                            .tint(headwindGradient)
                            .matchedGeometryEffect(id: "headwindPercentageGauge", in: animation)
                        }
                        
                        Gauge(value: Double(weatherImpact?.windSpeed ?? 0), in: 0...15){
                        } currentValueLabel: {
                            HStack{
                                
                                Text("\(truncateToOneDecmialPlace(weatherImpact?.windSpeed ?? 0)) m\\s").bold()
                                    
                            }
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(windSpeedGradient)
                        .matchedGeometryEffect(id: "windSpeedGauge", in: animation)
                        
                    }.padding()
                    
                } else {
                    /// expanded view
                    VStack{
                        HStack{
                            Text("\(selectedPath?.name ?? "")")
                                .font(.title)
                                .bold()
                                .padding()
                                .foregroundStyle(.primary)
                                .matchedGeometryEffect(id: "titleText", in: animation)
                        }
                        HStack{
                            
                            Text("Good Day to Cycle").bold()
                                .matchedGeometryEffect(id: "message", in: animation)

                            Image(systemName: "bicycle.circle.fill").foregroundStyle(.green)
                                .matchedGeometryEffect(id: "messageIcon", in: animation)
                            
                            Gauge(value: Double(weatherImpact?.crosswindPercentage ?? 0)/100){
                                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    } currentValueLabel: {
                                        HStack{
                                            Text("\(truncateToOneDecmialPlace(weatherImpact?.crosswindPercentage ?? 0))%").bold()
                                        }
                                        
                                    }
                                    .gaugeStyle(.accessoryCircular)
                                    .tint(crosswindGradient)
                                    .matchedGeometryEffect(id: "crosswindPercentageGauge", in: animation)
                            
                           
                            
                            Gauge(value: Double(weatherImpact?.tailwindPercentage ?? 0)/100){
                                Image(systemName: "arrow.right.to.line")
                            } currentValueLabel: {
                                HStack{
                                    Text("\(truncateToOneDecmialPlace(weatherImpact?.tailwindPercentage ?? 0))%").bold()
                                }
                                
                            }
                            .gaugeStyle(.accessoryCircular)
                            .tint(tailwindGradient)
                            .matchedGeometryEffect(id: "tailwindPercentageGauge", in: animation)
                            
                            Gauge(value: Double(weatherImpact?.headwindPercentage ?? 0)/100){
                                Image(systemName: "arrow.left.to.line")
                            } currentValueLabel: {
                                HStack{
                                    Text("\(truncateToOneDecmialPlace(weatherImpact?.headwindPercentage ?? 0))%").bold()
                                }
                            }
                            .gaugeStyle(.accessoryCircular)
                            .tint(headwindGradient)
                            .matchedGeometryEffect(id: "headwindPercentageGauge", in: animation)
                        }
                        
                        Gauge(value: Double(weatherImpact?.windSpeed ?? 0)/100){
                            Image(systemName: "arrow.left.to.line")
                        } currentValueLabel: {
                            HStack{
                                
                                Text("\(truncateToOneDecmialPlace(weatherImpact?.windSpeed ?? 0)) m\\s").bold()
                                    
                            }
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(windSpeedGradient)
                        .matchedGeometryEffect(id: "windSpeedGauge", in: animation)
                        Spacer()
                    }.padding()
                }
            }.onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
        }
    }
}

public func truncateToOneDecmialPlace(_ value: Double) -> String {
    return String(format: "%.1f", value)
}
/// given some
public func kelvinToCelsius(_ kelvin: Double) -> Double {
    return kelvin - 273.15
}
/// given some value, upper and lower bounds, return the nomalized value (0-1)
/// preconditions: upper > lower
public func nomalize(upper : Double, lower: Double, value: Double) -> Double {
    return ((value - lower) / (upper - lower))
}

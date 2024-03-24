//
//  RouteConditionPreviewView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 07/03/2024.
//

import SwiftUI
import Charts

struct RouteConditionPreviewView: View {
  //MARK: - Properties
  @Binding var selectedPath: CyclingPath?
  @Binding var weatherImpact: PathWeatherImpact?
  @Binding var coordinateWeatherImpact: [CoordinateWeatherImpact]?
  
  @Binding var cyclingScore: Int
  @Binding var cyclingMessage: String
  
  @Binding  var isFetching: Bool
  @State private var fetchTimestamp: Date?
  
  @Namespace var animation
  @State private var isExpanded = false
  
  let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
  let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
  let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
  let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
  let temperatureGradient = Gradient(colors: [ .purple, .blue ,.red])
  
  
  
  var body: some View {
    //MARK: - No Route Selected
    if selectedPath == nil{
      HStack{
        
        Text("No Route Selected")
          .font(.headline)
          .bold()
          .padding()
          .foregroundStyle(.primary)
      }.padding()
      
      
    } else if weatherImpact == nil{
      //MARK: - No Fetched Dataf
      HStack{
        
        Text("No Fetched Data for \(selectedPath!.name)")
          .font(.headline)
          .bold()
          .padding()
          .foregroundStyle(.primary)
          .matchedGeometryEffect(id: "titleText", in: animation)
        
        Image(systemName: "arrow.clockwise")
          .font(.headline)
          .padding()
          .foregroundStyle(.primary)
      }.padding()
        .frame(maxWidth: .infinity)
      
    }else {
      ZStack{
        if !isExpanded {
          //MARK: - Collapsed View
          
          VStack{
            HStack{
              withAnimation {
                Text("\(selectedPath?.name ?? "")")
                  .font(.headline)
                  .padding()
                  .bold()
                  .shadow(radius: 20)
                  .foregroundStyle(.primary)
                  .matchedGeometryEffect(id: "titleText", in: animation)
              }
            }
            .transition(.push(from: .bottom))
            .animation(.spring(duration: 2), value: selectedPath?.name ?? "")
            
            
            HStack{
              withAnimation {
                Text(cyclingMessage)
                  .font(.headline)
                  .fixedSize(horizontal: false, vertical: true)
                  .shadow(radius: 20)
                  .foregroundStyle(.gray)
                  .matchedGeometryEffect(id: "cyclingMessage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.spring(duration: 2), value: cyclingMessage)
              
              withAnimation {
                HStack{
                  Text("\(cyclingScore)").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
                  + Text("%").font(.caption).bold().foregroundStyle(.gray)
                  
                }
                .matchedGeometryEffect(id: "cyclingScore", in: animation)
                .shadow(radius: 20)
                .contentTransition(.numericText(value:  Double(cyclingScore * 100)))
                
              }
              .padding()
              .transition(.push(from: .bottom))
              .animation(.smooth(duration: 2), value: Double(cyclingScore))
              .sensoryFeedback(.impact, trigger: Double(cyclingScore))
              
            }

            
            
            withAnimation {
              Gauge(value: Double(weatherImpact?.windSpeed ?? 0), in: 0...15){
              } currentValueLabel: {
                HStack{
                  Text("\(truncateToOneDecmialPlace(weatherImpact?.windSpeed ?? 0)) m\\s").bold()
                }
                .contentTransition(.numericText(value: weatherImpact?.windSpeed ?? 0))
              }
              .gaugeStyle(.accessoryLinear)
              .tint(windSpeedGradient)
            }
            .transition(.push(from: .bottom))
            .animation(.snappy(duration: 2), value: windSpeedGradient)
            .matchedGeometryEffect(id: "windSpeedGauge", in: animation)
            
          }.padding()
          
          
          
        } else {
          //MARK: Expanded View
          VStack{
            HStack{
              withAnimation {
                Text("\(selectedPath?.name ?? "")")
                  .font(.headline)
                  .bold()
                  .padding()
                  .shadow(radius: 20)
                  .foregroundStyle(.primary)
                  .matchedGeometryEffect(id: "titleText", in: animation)
              }
            }
            .transition(.push(from: .bottom))
            .animation(.spring(duration: 2), value: selectedPath?.name ?? "")
            
            
            HStack{
              withAnimation {
                Text(cyclingMessage)
                  .font(.headline)
                  .fixedSize(horizontal: false, vertical: true)
                  .shadow(radius: 20)
                  .foregroundStyle(.gray)
                  .matchedGeometryEffect(id: "cyclingMessage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.spring(duration: 2), value: cyclingMessage)
              
              withAnimation {
                HStack{
                  Text("\(cyclingScore)").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
                  + Text("%").font(.caption).bold().foregroundStyle(.gray)
                  
                }
                .matchedGeometryEffect(id: "cyclingScore", in: animation)
                .shadow(radius: 20)
                .contentTransition(.numericText(value:  Double(cyclingScore * 100)))
                
              }
              .padding()
              .transition(.push(from: .bottom))
              .animation(.smooth(duration: 2), value: Double(cyclingScore))
              .sensoryFeedback(.impact, trigger: Double(cyclingScore))
              
            }
            
            
            HStack{
              //temperature gauge
              withAnimation {
                Gauge(value: Double(kelvinToCelsius(weatherImpact?.temperature ?? 0)), in: -20...40){
                  Image(systemName: "thermometer.medium")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(kelvinToCelsius(weatherImpact?.temperature ?? 0)))°").bold()
                  }.contentTransition(.numericText(value: kelvinToCelsius(weatherImpact?.temperature ?? 0)))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(temperatureGradient)
                .animation(.spring(duration: 2), value: kelvinToCelsius(weatherImpact?.temperature ?? 0))
                .matchedGeometryEffect(id: "temperatureGauge", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: kelvinToCelsius(weatherImpact?.temperature ?? 0))
              
              //crosswindPercentage gauge
              withAnimation {
                Gauge(value: Double(weatherImpact?.crosswindPercentage ?? 0)/100){
                  Image(systemName: "arrow.down.right.and.arrow.up.left")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(weatherImpact?.crosswindPercentage ?? 0))%").bold()
                  }.contentTransition(.numericText(value: weatherImpact?.crosswindPercentage ?? 0))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(crosswindGradient)
                .matchedGeometryEffect(id: "crosswindPercentageGauge", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: Double(weatherImpact?.crosswindPercentage ?? 0))
              
              //tailwindPercentage gauge
              withAnimation {
                Gauge(value: Double(weatherImpact?.tailwindPercentage ?? 0)/100){
                  Image(systemName: "arrow.right.to.line")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(weatherImpact?.tailwindPercentage ?? 0))%").bold()
                  }.contentTransition(.numericText(value: weatherImpact?.tailwindPercentage ?? 0))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(tailwindGradient)
                .matchedGeometryEffect(id: "tailwindPercentageGuage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: Double(weatherImpact?.tailwindPercentage ?? 0))
              
              //headwindPercentage gauge
              withAnimation {
                Gauge(value: Double(weatherImpact?.headwindPercentage ?? 0)/100){
                  Image(systemName: "arrow.left.to.line")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(weatherImpact?.headwindPercentage ?? 0))%").bold()
                  }.contentTransition(.numericText(value: weatherImpact?.headwindPercentage ?? 0))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(headwindGradient)
                .matchedGeometryEffect(id: "headwindPercentageGuage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: Double(weatherImpact?.headwindPercentage ?? 0))
              
            }
            
            withAnimation {
              Gauge(value: Double(weatherImpact?.windSpeed ?? 0), in: 0...15){
              } currentValueLabel: {
                HStack{
                  Text("\(truncateToOneDecmialPlace(weatherImpact?.windSpeed ?? 0)) m\\s").bold()
                }
                .contentTransition(.numericText(value: weatherImpact?.windSpeed ?? 0))
              }
              .gaugeStyle(.accessoryLinear)
              .tint(windSpeedGradient)
            }
            .matchedGeometryEffect(id: "windSpeedGauge", in: animation)
            .transition(.push(from: .bottom))
            .animation(.snappy(duration: 2), value: windSpeedGradient)
  
          
          
        Text("Headwinds")
          .font(.headline)
          .bold()
          .padding()
          .shadow(radius: 20)
          .foregroundStyle(.primary)
          .matchedGeometryEffect(id: "headwindsText", in: animation)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        Chart{
          ForEach(Array(coordinateWeatherImpact!.enumerated()), id: \.offset){ index, object in
            
            LineMark(x: .value("Coordinate", index), y: .value("Percentage", object.headwindPercentage ?? 0))
              .interpolationMethod(.catmullRom)
              .lineStyle(StrokeStyle(lineWidth: 2))
              .foregroundStyle(.gray)
          }
        }
        .chartYAxis {
          AxisMarks(
            format: Decimal.FormatStyle.Percent.percent.scale(1),
            values: [0, 50, 100]
          )
        }
        .padding()
        .frame(height: 200)
        
        
        
        
      }.padding()
    }
  }.onTapGesture {
    withAnimation {
      cyclingScore = Int(Double( WeatherImpactAnalysisEngine.computeCyclingScore(for: weatherImpact!) * 100))
      isExpanded.toggle()
      
    }
  }
}
}
}

//MARK: - Functions
public func truncateToOneDecmialPlace(_ value: Double) -> String {
  return String(format: "%.1f", value)
}
/// given some
public func kelvinToCelsius(_ kelvin: Double) -> Double {
  return kelvin - 273.15
}

public func meterPerSecondToKilometerPerHour(_ mps: Double) -> Double {
  return mps * 3.6
}

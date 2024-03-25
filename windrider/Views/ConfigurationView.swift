//
//  ConfigurationView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 20/03/2024.
//
//
//  SettingsView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 20/03/2024.
//

import SwiftUI
import SwiftData

struct ConfigurationView: View {
  @Environment(\.modelContext) private var modelContext
  @Binding var cyclingScore : Int
  @Binding var pathImpact: PathImpact
  
  
  @State private var APIKey: String = ""
  @State private var upperTemperature: Double = 0.0
  @State private var idealTemperature: Double = 0.0
  @State private var upperWindSpeed: Double = 0.0
  @State private var headwindWeight: Double = 0.0
  @State private var crosswindWeight: Double = 0.0
  @State private var tailwindWeight: Double = 0.0
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("API Weather Key")) {
          //mono-spaced font
          TextField("OpenWeatherMap API Key", text: $APIKey).font(.system(.body, design: .monospaced))
        }
        
        Section(header: Text("Temperature")) {
          
          //Upper Temperature Text
          VStack(alignment: .leading){
            HStack{
              Text("Upper Temperature ").font(.caption).foregroundStyle(.gray)
              Image(systemName: "thermometer.sun.fill").font(.caption).foregroundStyle(.gray)
            }
            withAnimation {
              
              HStack{
                Text("\(String(format: "%.1f", upperTemperature) )").font(.largeTitle).bold().foregroundStyle(temperatureToColor(temperature: upperTemperature))
                + Text(" °C").font(.headline).bold().foregroundStyle(.gray)
                
              }.contentTransition(.numericText(value: upperTemperature))

            }
          }.padding()
            .transition(.push(from: .bottom))
            .animation(.smooth(duration: 2), value:upperTemperature/2 )
            .sensoryFeedback(.increase, trigger: upperTemperature/2)
          
          Slider(value: $upperTemperature, in: 0...50, step: 0.5)
          
          
          //Ideal Temperature Text
          VStack(alignment: .leading){
            HStack{
              Text("Ideal Temperature ").font(.caption).foregroundStyle(.gray)
              Image(systemName: "thermometer.variable.and.figure").font(.caption).foregroundStyle(.gray)
            }
            withAnimation {
              HStack{
                Text("\(String(format: "%.1f", idealTemperature) )").font(.largeTitle).bold().foregroundStyle(temperatureToColor(temperature: idealTemperature))
                + Text(" °C").font(.headline).bold().foregroundStyle(.gray)
              }
              .contentTransition(.numericText(value: idealTemperature))
            }
          }.padding()
            .transition(.push(from: .bottom))
            .animation(.smooth(duration: 2), value:idealTemperature/2 )
            .sensoryFeedback(.increase, trigger: idealTemperature/2)
          
          Slider(value: $idealTemperature, in: 0...45, step: 0.5) {
            Text("Ideal Temperature")
          }
        }
        
        
        Section(header: Text("Wind Speed")) {
          VStack(alignment: .leading){
            HStack{
              Text("Upper Plauseable Wind Speed ").font(.caption).foregroundStyle(.gray)
              Image(systemName: "wind").font(.caption).foregroundStyle(.gray)
            }
            withAnimation {
              HStack{
                Text("\(String(format: "%.1f", upperWindSpeed) )").font(.largeTitle).bold().foregroundStyle(windSpeedToColor(windSpeed: upperWindSpeed))
                +
                Text(" m/s").font(.headline).bold().foregroundStyle(.gray)
              }.contentTransition(.numericText(value: upperWindSpeed))
            }
          }.padding()
            .transition(.push(from: .bottom))
            .animation(.smooth(duration: 2), value:upperWindSpeed)
            .sensoryFeedback(.increase, trigger: upperWindSpeed)
          
          Slider(value: $upperWindSpeed, in: 0...70, step: 1){
            Text("Upper Plauseable WindSpeed")
          }        }
        
        Section(header: Text("Wind Weight")) {
          
          VStack(alignment: .leading){
            HStack{
              Text("Headwind Weight ").font(.caption).foregroundStyle(.gray)
              Image(systemName: "arrow.up").font(.caption).foregroundStyle(.gray)
            }
            withAnimation {
              HStack{
                Text("\(String(format: "%.1f", headwindWeight) )").font(.largeTitle).bold().foregroundStyle(muliplierToColor(multiplier: headwindWeight))
                + Text("X").font(.headline).bold().foregroundStyle(.gray)
              }.contentTransition(.numericText(value: headwindWeight))
            }
          }.padding()
            .transition(.push(from: .bottom))
            .animation(.smooth(duration: 2), value:headwindWeight)
            .sensoryFeedback(.increase, trigger: headwindWeight)
          Slider(value: $headwindWeight, in: 0...5, step: 0.05)
          
          VStack(alignment: .leading){
            HStack{
              Text("Crosswind Weight ").font(.caption).foregroundStyle(.gray)
              Image(systemName: "arrow.left.and.right").font(.caption).foregroundStyle(.gray)
            }
            withAnimation {
              HStack{
                Text("\(String(format: "%.1f", crosswindWeight) )").font(.largeTitle).bold().foregroundStyle(muliplierToColor(multiplier: crosswindWeight))
                + Text("X").font(.headline).bold().foregroundStyle(.gray)
              }.contentTransition(.numericText(value: crosswindWeight))
            }
          }.padding()
            .transition(.push(from: .bottom))
            .animation(.smooth(duration: 2), value:crosswindWeight)
            .sensoryFeedback(.increase, trigger: crosswindWeight)
        
        
          Slider(value: $crosswindWeight, in: 0...5, step: 0.05)
          
          VStack(alignment: .leading){
            HStack{
              Text("Tailwind Weight ").font(.caption).foregroundStyle(.gray)
              Image(systemName: "arrow.down").font(.caption).foregroundStyle(.gray)
            }
            withAnimation {
              HStack{
                Text("\(String(format: "%.1f", tailwindWeight) )").font(.largeTitle).bold().foregroundStyle(muliplierToColor(multiplier: tailwindWeight))
                + Text("X").font(.headline).bold().foregroundStyle(.gray)
              }.contentTransition(.numericText(value: tailwindWeight))
            }
          }.padding()
            .transition(.push(from: .bottom))
            .animation(.smooth(duration: 2), value:tailwindWeight)
            .sensoryFeedback(.increase, trigger: tailwindWeight)
          
          
          Slider(value: $tailwindWeight, in: 0...10, step: 0.1)
            
          }
          
        }
      .navigationBarTitle("Configuration")
      }
      
      .onAppear {
        guard let defaults = UserDefaults(suiteName: "group.com.daiigr.windrider") else {
          return
        }
        
          APIKey = defaults.string(forKey : "APIKey") ?? ""
         upperTemperature = defaults.double(forKey: "upperTemperature")
         idealTemperature = defaults.double(forKey: "idealTemperature")
         upperWindSpeed = defaults.double(forKey: "upperWindSpeed")
         headwindWeight = defaults.double(forKey: "headwindWeight")
         tailwindWeight = defaults.double(forKey: "tailwindWeight")
         crosswindWeight = defaults.double(forKey: "crosswindWeight")
      }
      .onDisappear {
        guard let defaults = UserDefaults(suiteName: "group.com.daiigr.windrider") else {
          return
        }
        defaults.set(APIKey , forKey: "APIKey")
        defaults.set(upperTemperature, forKey: "upperTemperature")
        defaults.set(idealTemperature, forKey: "idealTemperature")
        defaults.set(upperWindSpeed, forKey: "upperWindSpeed")
        defaults.set(headwindWeight, forKey: "headwindWeight")
        defaults.set(crosswindWeight, forKey: "crosswindWeight")
        defaults.set(tailwindWeight, forKey: "tailwindWeight")
        cyclingScore = Int(Double( ImpactCalculator.calculateCyclingScore(for: pathImpact)))
      }
    }
  }
  
  func temperatureToColor(temperature: Double) -> Color {
    if isDarkMode() {
      // Dark mode colors
      if temperature < 10 {
        return Color(red: 0 , green: 0.5, blue: 1, opacity: 1) // A cooler, softer blue
      } else if temperature < 25 {
        return Color(red: 0.4, green: 0.8, blue: 0.4, opacity: 1) // A softer, lighter green
      } else {
        return Color(red: 1, green: 0.55, blue: 0, opacity: 1) // A warmer, orangy color
      }
      
    } else {
      // softer colors
      if temperature < 10 {
        return Color(red: 0 , green: 0.5, blue: 1, opacity: 0.7) // A cooler, softer blue
      } else if temperature < 25 {
        return Color(red: 0.4, green: 0.8, blue: 0.4, opacity: 0.7) // A softer, lighter green
      } else {
        return Color(red: 1, green: 0.55, blue: 0, opacity: 0.7) // A warmer, orangy color
      }
    }
    
  }
  func windSpeedToColor(windSpeed: Double) -> Color {
    if isDarkMode(){
        if windSpeed < 20 {
          return Color.gray
        } else if windSpeed < 40 {
          return Color.orange
        } else {
          return Color.red
        }
    } else {
      if windSpeed < 20 {
        return Color.gray.opacity(0.7)
      } else if windSpeed < 40 {
        return Color.orange.opacity(0.7)
      } else {
        return Color.red.opacity(0.7)
      }
    }
  }

  
  func muliplierToColor(multiplier: Double) -> Color {
    if multiplier < 1 {
      return Color.gray.opacity(0.7)
    } else if multiplier < 2 {
      return Color.orange.opacity(0.7)
    } else {
      return Color.purple.opacity(0.7)
    }
  }
  func isDarkMode() -> Bool {
    return UIScreen.main.traitCollection.userInterfaceStyle == .dark
  }
  


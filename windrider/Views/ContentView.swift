//
//  ContentView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var paths: [CyclingPath]
  @State private var selectedRoute: BikeRoute?
  @State var selectedPath: CyclingPath?
  @State var selectedFileURL: URL?
  // Weather impact analysis
  @State private var weatherImpact: PathWeatherImpact?
  @State private var coordinateWeatherImpact: [CoordinateWeatherImpact]?
  
  @State var isRouteSelectionViewPresented = false
  @State var isRouteRecorderViewPresented = false
  @State var isFilePickerPresented = false
  @State var isSettingsViewPresented = false
  @State var isFetching = false
  
  @State var polylineSegements: [PolylineSegement]?
  @State var cyclingPathRecorder: CyclingPathRecorder = CyclingPathRecorder()
  @State var hasSettingStateChanged: Bool = false
  
  @State var cyclingScore: Int = 0
  @State var cyclingMessage: String = ""
  
  @State var pathImpact: PathImpact = PathImpact()
  @State var coordinateImpacts: [CoordinateImpact] = []
  
  var body: some View {
    ZStack {
      // Map view as the base layer
      if !paths.isEmpty{
        // there is a selected path
        if polylineSegements != nil{
          Map {
            if let polylineSegements = polylineSegements {
              ForEach(Array(polylineSegements.enumerated()), id: \.offset) { index , object in
                MapPolyline(coordinates: object.coordinateArray, contourStyle:
                    .geodesic).stroke(lineWidth: 3).stroke(object.color)
              }
            }
          }.environment(\.colorScheme, .dark)
          
          VStack{
            RouteConditionPreviewView(selectedPath: $selectedPath,
                                      pathImpact: $pathImpact,
                                      coordinateImpacts: $coordinateImpacts,
                                      cyclingScore: $cyclingScore,
                                      cyclingMessage: $cyclingMessage,
                                      isFetching: $isFetching)
            
            .padding(.vertical, 30)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            .zIndex(1) // Ensure it stays on top
            .ignoresSafeArea()
            Spacer()
          }
          
        } else  {
          VStack{
            ContentUnavailableView{
              Label("No Weather Data Pulled",systemImage: "icloud.and.arrow.down")
            } description:{
              Text("Pull the Latest Weather Data")
            } actions:{
              Button("Pull Data"){
                guard let selectedPath = selectedPath else {
                  isFetching = false
                  return
                }
                guard let defaults = UserDefaults(suiteName: "group.com.daiigr.windrider") else {
                  isFetching = false
                  return
                }
                let apikey = defaults.string(forKey: "APIKey") ?? ""
                AnalysisEngine.analyseImpact(for: selectedPath, with: OpenWeatherMapAPI(openWeatherMapAPIKey: apikey)){ result  in
                  switch result{
                    case .success(let response):
                      coordinateImpacts = response.0
                      pathImpact = response.1
                      
                      cyclingScore = ImpactCalculator.calculateCyclingScore(for: pathImpact)
                      cyclingMessage = ImpactVisualizer.constructCyclingMessage(for: pathImpact)
                      
                      polylineSegements = ImpactVisualizer.constructWeatherImpactPolyline(coordinateImpacts, cyclingPath: selectedPath)
                      // create polyline segments
                    case .failure(let error):
                      return
                  }
                }
              }.buttonStyle(.bordered)
            }
          }
        }
        
        

      }   else {
        VStack{
          ContentUnavailableView{
            Label("you don't have any routes",systemImage: "bicycle")
          } description:{
            Text("Select a route from the list below")
          } actions:{
            Button("Import Route"){
              isFilePickerPresented = true
            }.buttonStyle(.bordered)
              .sheet(isPresented: $isFilePickerPresented, content: {
                DocumentPicker(selectedPath: $selectedPath)
                  .ignoresSafeArea()
              })
          }
        }
      }
      
      
      
      
      
      // Buttons positioned at the bottom or another place
      VStack {
        Spacer() // Pushes the content to the bottom
        HStack {
          Image(systemName: "list.bullet")
            .padding()
            .foregroundColor(.primary)
            .sensoryFeedback(.increase, trigger: isRouteSelectionViewPresented)
            .onTapGesture {
              isRouteSelectionViewPresented = true
            }.sheet(isPresented: $isRouteSelectionViewPresented, content: {
              RouteSelectionView(selectedPath: $selectedPath,
                                 polylineSegements: $polylineSegements,
                                 isRouteSelectionViewPresented: $isRouteSelectionViewPresented)
            })
          
          
          
          Image(systemName: !isFetching ?  "cloud.sun" : "icloud.and.arrow.down" )
            .padding()
            .foregroundColor(.primary)
            .sensoryFeedback(.increase, trigger: isSettingsViewPresented)
            .contentTransition(.symbolEffect(.replace))
            .onTapGesture {
              isFetching = true
              guard let selectedPath = selectedPath else {
                isFetching = false
                return
              }
              guard let defaults = UserDefaults(suiteName: "group.com.daiigr.windrider") else {
                isFetching = false
                return
              }
              let apikey = defaults.string(forKey: "APIKey") ?? ""
              AnalysisEngine.analyseImpact(for: selectedPath, with: OpenWeatherMapAPI(openWeatherMapAPIKey: apikey)){ result  in
                switch result{
                  case .success(let response):
                    coordinateImpacts = response.0
                    pathImpact = response.1
                    
                    cyclingScore = ImpactCalculator.calculateCyclingScore(for: pathImpact)
                    cyclingMessage = ImpactVisualizer.constructCyclingMessage(for: pathImpact)
                    
                    polylineSegements = ImpactVisualizer.constructWeatherImpactPolyline(coordinateImpacts, cyclingPath: selectedPath)
                    // create polyline segments
                  case .failure(let error):
                    return
                }
              }
              
            }
          
          Image(systemName: "gearshape")
            .padding()
            .foregroundColor(.primary)
            .sensoryFeedback(.increase, trigger: isSettingsViewPresented)
            .onTapGesture {
              isSettingsViewPresented.toggle()
            }.sheet(isPresented: $isSettingsViewPresented, content: {
              ConfigurationView(cyclingScore: $cyclingScore, pathImpact: $pathImpact)
            })
        }
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25))
      }
      .padding() // Add some padding around the HStack for better spacing
    }.onAppear{
      selectedPath = ContentView.getDefaultPath(for: paths)
    }
  }
  
  
  static public func getDefaultPath(for paths: [CyclingPath]) -> CyclingPath? {
    
    guard !paths.isEmpty else {
      return nil
    }
    
    // first get the first favourite path
    for path in paths {
      if path.isFavorite {
        return path
      }
    }
    
    // if no favourite path, get the first path
    if let path = paths.first {
      return path
    }
    return nil
  }
}

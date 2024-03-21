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
	
	var body: some View {
		ZStack {
			// Map view as the base layer
			if !paths.isEmpty{
				// there is a selected path
				Map {
					if let polylineSegements = polylineSegements {
						ForEach(Array(polylineSegements.enumerated()), id: \.offset) { index , object in
							MapPolyline(coordinates: object.coordinateArray, contourStyle:
									.geodesic).stroke(lineWidth: 3).stroke(object.color)
						}
					} else if let selectedPath = selectedPath{
						MapPolyline(coordinates: selectedPath.getCoordinates(), contourStyle: .geodesic).stroke(lineWidth: 3).stroke(Color.blue)
					}
				}
				VStack{
					RouteConditionPreviewView(selectedPath: $selectedPath,
											  weatherImpact: $weatherImpact,
											  coordinateWeatherImpact: $coordinateWeatherImpact,
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
			} else {
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
					Button {
						isRouteSelectionViewPresented = true
					} label: {
						Image(systemName: "list.bullet")
							.padding()
							.foregroundColor(.primary)
							.background(.ultraThickMaterial)
							.clipShape(Circle())
					}.sheet(isPresented: $isRouteSelectionViewPresented, content: {
						RouteSelectionView(selectedPath: $selectedPath,
										   polylineSegements: $polylineSegements,
										   isRouteSelectionViewPresented: $isRouteSelectionViewPresented)
					})
					
					
					Button {
						
						guard let selectedPath = selectedPath else { return}
						guard let defaults = UserDefaults(suiteName: "group.com.daiigr.windrider") else {
							return
						}
						let apikey = defaults.string(forKey: "APIKey") ?? ""
						let engine = WeatherImpactAnalysisEngine()
						engine.analyseImpact(for: selectedPath, with: OpenWeatherMapAPI(openWeatherMapAPIKey: apikey)) { result in
							switch result{
								case .success(let response):
									coordinateWeatherImpact = response.0
									weatherImpact = response.1
									
									cyclingScore = Int(Double( WeatherImpactAnalysisEngine.computeCyclingScore(for: weatherImpact!) * 100))
									cyclingMessage = WeatherImpactAnalysisEngine.shouldICycle(for: weatherImpact!)
									// create polyline segments
									polylineSegements = WeatherImpactAnalysisEngine.constructWeatherImpactPolyline(coordinateWeatherImpacts: coordinateWeatherImpact!, cyclingPath: selectedPath)
									
								case .failure(_):
									return
							}
						}
					} label: {
						Image(systemName: "cloud.sun")
							.padding()
							.foregroundColor(.primary)
							.background(.ultraThickMaterial)
							.clipShape(Circle())
						
					}
					
					Button {
						isRouteRecorderViewPresented = true
					} label: {
						Image(systemName: "record.circle")
							.padding()
							.foregroundColor(.red)
							.background(.ultraThickMaterial)
							.clipShape(Circle())
					}.sheet(isPresented: $isRouteRecorderViewPresented, content: {
						PathRecorderView(isPathRecorderViewPresented: $isRouteRecorderViewPresented, cyclingPathRecorder: $cyclingPathRecorder)
					})
					
					Button{
						isSettingsViewPresented.toggle()
					} label: {
						Image(systemName: "gearshape")
							.padding()
							.foregroundColor(.primary)
							.background(.ultraThickMaterial)
							.clipShape(Circle())
						
					}.sheet(isPresented: $isSettingsViewPresented, content: {
						ConfigurationView(cyclingScore: $cyclingScore, weatherImpact: $weatherImpact)
					})
				}
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

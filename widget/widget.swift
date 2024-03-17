//
//  widget.swift
//  widget
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import WidgetKit
import SwiftUI
import SwiftData
import MapKit

struct Provider: TimelineProvider {
	@MainActor func placeholder(in context: Context) -> PathWeatherImpactEntry {
		let dispatchGroup = DispatchGroup()
		var result: PathWeatherImpactEntry?
		
		dispatchGroup.enter()
		fetchPathWeatherImpactEntry() { entry in
			result = entry
			dispatchGroup.leave()
		}
		
		dispatchGroup.wait()
		return result!
	}


   @MainActor func getSnapshot(in context: Context, completion: @escaping (PathWeatherImpactEntry)   -> ()){
	   fetchPathWeatherImpactEntry(){ entry in
		   completion(entry)
	   }
	   
	}

	@MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ())  {
		var entries: [PathWeatherImpactEntry] = []
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		
			for hourOffset in 0 ..< 5 {
				let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
				
					let dispatchGroup = DispatchGroup()
					var entry: PathWeatherImpactEntry?
				
					dispatchGroup.enter()
					fetchPathWeatherImpactEntry() { entry in
						dispatchGroup.leave()
					}
					dispatchGroup.wait()
				
					guard let unwrappedEntry = entry else {
						return
					}
					entries.append(unwrappedEntry)
			
			}

			let timeline = Timeline(entries: entries, policy: .atEnd)
			completion(timeline)
	}
	
	
	/// fetch [CyclingPath] array from SwiftData
	///
	/// - Returns: [CyclingPath] array
	@MainActor private func fetchCyclingRoutes() -> [CyclingPath] {
		// fetch the model container if it exists else return an empty array
		guard let modelContainer = try? ModelContainer(for: CyclingPath.self) else {
			return []
		}
		let cyclingPathDescriptor = FetchDescriptor<CyclingPath>()
		
		// fetch the array of cycling paths if it exists else return an empty array
		guard let cyclingPath = try? modelContainer.mainContext.fetch(cyclingPathDescriptor) else {
			return []
		}
		
		// sort the cycling paths by the date they were created
		let sortedCyclingPath = cyclingPath.sorted { $0.createdAt > $1.createdAt }
		
		// return the sorted array of cycling paths
		return sortedCyclingPath
	}
	
	
	
	@MainActor private func getFavoriteCyclingPath(for cyclingPaths: [CyclingPath]) -> CyclingPath? {
		let sortedCyclingPath = cyclingPaths.sorted { $0.createdAt > $1.createdAt }
		for path in sortedCyclingPath{
			if path.isFavorite{
				return path
			}
		}
		return nil
	}
	
	
	
	@MainActor private func fetchPathWeatherImpactEntry(completion: @escaping (PathWeatherImpactEntry) -> Void) {
		let cyclingPaths = fetchCyclingRoutes()
		
		let date = Date()
		guard let cyclingPath = getFavoriteCyclingPath(for: cyclingPaths) else {
			completion(PathWeatherImpactEntry(date: Date(), cyclingScore: 0, message: "No cycling path found", temperature: 0, windSpeed: 0, headwindPercentage: 0, tailwindPercentage: 0, crosswindPercentage: 0, cyclingScoreColor: .green, successfullyFetched: false))
			return
		}
		
		let engine = WeatherImpactAnalysisEngine()
		engine.analyseImpact(for: cyclingPath, with: OpenWeatherMapAPI(openWeatherMapAPIKey: "22ab22ed87d7cc4edae06caa75c7f449")) { result in
			switch result {
			case .success(let response):
				 let weatherImpact = response.1
				
				let cyclingScore = WeatherImpactAnalysisEngine.computeCyclingScore(for: weatherImpact)
				let message = WeatherImpactAnalysisEngine.shouldICycle(for: weatherImpact)
				
				let pathWeatherImpactEntry = PathWeatherImpactEntry(date: date,
																	cyclingScore: cyclingScore,
																	message: message,
																	temperature: weatherImpact.temperature,
																	windSpeed: weatherImpact.windSpeed,
																	headwindPercentage: weatherImpact.headwindPercentage ?? 0 ,
																	tailwindPercentage: weatherImpact.tailwindPercentage ?? 0,
																	crosswindPercentage: weatherImpact.crosswindPercentage ?? 0,
																	cyclingScoreColor: WeatherImpactAnalysisEngine.colorForPercentage(cyclingScore),
																	successfullyFetched: true)
				completion(pathWeatherImpactEntry)
				
			case .failure(_):
					let failurePathWeatherImpactEntry = PathWeatherImpactEntry(date: date, cyclingScore: 0, message: "Failed to fetch weather data", temperature: 0, windSpeed: 0, headwindPercentage: 0, tailwindPercentage: 0, crosswindPercentage: 0, cyclingScoreColor: .green, successfullyFetched: false)
				completion(failurePathWeatherImpactEntry)
			}
		}
	}
}


//end of provider

struct accessoryCircularWidgetView: View{
	var entry: Provider.Entry
	var body: some View{
		Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
			Image(systemName: "arrow.left.to.line")
		} currentValueLabel: {
			HStack{
				Text("\(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").bold()
			}
			
		}
		.gaugeStyle(.accessoryCircular)
	}
}


struct accessoryInlineWidgetView: View {
	var entry: Provider.Entry
	var body: some View {
		Text("Headwinds of \(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").font(.title)
	}
}

struct accessoryRectangularWidgetView: View {
	var entry: Provider.Entry
	var body: some View {
		HStack{
			Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalCrosswindPercentage ?? 0)/100){
				Image(systemName: "arrow.down.right.and.arrow.up.left")
			} currentValueLabel: {
				HStack{
					Text("\(entry.bikeRoute.bikeRouteCondition?.totalCrosswindPercentage ?? 0)%").bold()
				}
				
			}
			.gaugeStyle(.accessoryCircular)
			
			Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalTailwindPercentage ?? 0)/100){
				Image(systemName: "arrow.right.to.line")
			} currentValueLabel: {
				HStack{
					Text("\(entry.bikeRoute.bikeRouteCondition?.totalTailwindPercentage ?? 0)%").bold()
				}
				
			}
			.gaugeStyle(.accessoryCircular)
			Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
				Image(systemName: "arrow.left.to.line")
			} currentValueLabel: {
				HStack{
					Text("\(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").bold()
				}
				
			}
			.gaugeStyle(.accessoryCircular)
		}
	   
		HStack{
			Image(systemName: "gauge.with.dots.needle.bottom.50percent")
			Text("Speeds of ") + Text("\(entry.bikeRoute.bikeRouteCondition?.windSpeed ?? 0)m/s").bold()
		}
	}
}

struct systemSmallWidgetView: View {
	var entry: Provider.Entry
	let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
	let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
	let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
	let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
	
	var body: some View {
		VStack{
			
				Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalCrosswindPercentage ?? 0)/100){
					Image(systemName: "arrow.down.right.and.arrow.up.left")
				} currentValueLabel: {
					HStack{
						Text("\(entry.bikeRoute.bikeRouteCondition?.totalCrosswindPercentage ?? 0)%").bold()
					}
					
				}
				.gaugeStyle(.accessoryCircular)
				.tint(crosswindGradient)
				
			
			HStack{
				Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalTailwindPercentage ?? 0)/100){
					Image(systemName: "arrow.right.to.line")
				} currentValueLabel: {
					HStack{
						Text("\(entry.bikeRoute.bikeRouteCondition?.totalTailwindPercentage ?? 0)%").bold()
					}
					
				}
				.gaugeStyle(.accessoryCircular)
				.tint(tailwindGradient)
				Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
					Image(systemName: "arrow.left.to.line")
				} currentValueLabel: {
					HStack{
						Text("\(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").bold()
					}
					
				}
				.gaugeStyle(.accessoryCircular)
				.tint(headwindGradient)
			}
			Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.windSpeed ?? 0)/100){
				Image(systemName: "arrow.left.to.line")
			} currentValueLabel: {
				HStack{
					Text("\(entry.bikeRoute.bikeRouteCondition?.windSpeed ?? 0) m\\s").bold()
				}
				
			}
			.gaugeStyle(.accessoryLinear)
			.tint(windSpeedGradient)
			
		   

		}
	}
}

struct systemMediumWidgetView: View{
	var entry: Provider.Entry
	let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
	let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
	let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
	let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
	let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
	
	var body: some View{
		VStack{
			
				Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalCrosswindPercentage ?? 0)/100){
					Image(systemName: "arrow.down.right.and.arrow.up.left")
				} currentValueLabel: {
					HStack{
						Text("\(entry.bikeRoute.bikeRouteCondition?.totalCrosswindPercentage ?? 0)%").bold()
					}
					
				}
				.gaugeStyle(.accessoryCircular)
				.tint(crosswindGradient)
				
			
			HStack{
				Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalTailwindPercentage ?? 0)/100){
					Image(systemName: "arrow.right.to.line")
				} currentValueLabel: {
					HStack{
						Text("\(entry.bikeRoute.bikeRouteCondition?.totalTailwindPercentage ?? 0)%").bold()
					}
					
				}
				.gaugeStyle(.accessoryCircular)
				.tint(tailwindGradient)
				Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
					Image(systemName: "arrow.left.to.line")
				} currentValueLabel: {
					HStack{
						Text("\(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)%").bold()
					}
					
				}
				.gaugeStyle(.accessoryCircular)
				.tint(headwindGradient)
			}
			Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.windSpeed ?? 0)/100){
				Image(systemName: "arrow.left.to.line")
			} currentValueLabel: {
				HStack{
					Text("\(entry.bikeRoute.bikeRouteCondition?.windSpeed ?? 0) m\\s").bold()
				}
				
			}
			.gaugeStyle(.accessoryLinear)
			.tint(windSpeedGradient)
			
		   

		}
	}
}

struct systemLargeWidgetView: View{
	var entry: Provider.Entry
	
	var body: some View{
		VStack{
			
		}
	}
}


struct widgetEntryView : View {
	var entry: Provider.Entry
	@Environment(\.widgetFamily) var widgetFamily
	var body: some View {
		switch widgetFamily{
		case .accessoryCircular:
			accessoryCircularWidgetView(entry: entry)
		case .accessoryInline:
			accessoryInlineWidgetView(entry: entry)
		case .accessoryRectangular:
			accessoryRectangularWidgetView(entry: entry)
		case .systemSmall:
			systemSmallWidgetView(entry: entry)
		case .systemMedium:
			systemMediumWidgetView(entry: entry)
		case .systemLarge:
			systemLargeWidgetView(entry: entry)
		default:
			Text("not Implemented")
		}
	}
}


struct widget: Widget {
	let kind: String = "widget"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider()) { entry in
			if #available(iOS 17.0, *) {
				widgetEntryView(entry: entry)
					.containerBackground(.fill.tertiary, for: .widget)
			} else {
				widgetEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("My Widget")
		.description("This is an example widget.")
		.supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular])
	}
}

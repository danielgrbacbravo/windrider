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
		let placeholderPathWeatherImpactEntry = PathWeatherImpactEntry(date: Date(),name: "", cyclingScore: 0, message: "Fetching...", temperature: 0, windSpeed: 0, headwindPercentage: 0, tailwindPercentage: 0, crosswindPercentage: 0, cyclingScoreColor: .gray, successfullyFetched: false)
		return placeholderPathWeatherImpactEntry
	}
	
	
	@MainActor func getSnapshot(in context: Context, completion: @escaping (PathWeatherImpactEntry)   -> ()){
		let date = Date()
		fetchPathWeatherImpactEntry(for: date){ entry in
			completion(entry)
		}
		
	}
	
	@MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		var entries: [PathWeatherImpactEntry] = []
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		
		let dispatchGroup = DispatchGroup()
		
		for hourOffset in 0 ..< 5 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			dispatchGroup.enter()
			fetchPathWeatherImpactEntry(for: entryDate) { entry in
				entries.append(entry)
				dispatchGroup.leave()
			}
		}
		
		dispatchGroup.notify(queue: .main) {
			let timeline = Timeline(entries: entries, policy: .atEnd)
			completion(timeline)
		}
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
	
	
	
	@MainActor private func fetchPathWeatherImpactEntry(for date: Date, completion: @escaping (PathWeatherImpactEntry) -> Void) {
		let cyclingPaths = fetchCyclingRoutes()
		guard let cyclingPath = getFavoriteCyclingPath(for: cyclingPaths) else {
			completion(PathWeatherImpactEntry(date: date,name: "", cyclingScore: 0, message: "No cycling path found", temperature: 0, windSpeed: 0, headwindPercentage: 0, tailwindPercentage: 0, crosswindPercentage: 0, cyclingScoreColor: .green, successfullyFetched: false))
			return
		}
		
		let engine = WeatherImpactAnalysisEngine()
		engine.analyseImpact(for: cyclingPath, with: OpenWeatherMapAPI(openWeatherMapAPIKey: "22ab22ed87d7cc4edae06caa75c7f449")) { result in
			switch result {
				case .success(let response):
					let entry = response.1
					
					let cyclingScore = WeatherImpactAnalysisEngine.computeCyclingScore(for: entry)
					let message = WeatherImpactAnalysisEngine.shouldICycle(for: entry)
					
					let pathWeatherImpactEntry = PathWeatherImpactEntry(date: date, name: cyclingPath.name,
																		cyclingScore: cyclingScore,
																		message: message,
																		temperature: entry.temperature,
																		windSpeed: entry.windSpeed,
																		headwindPercentage: entry.headwindPercentage ?? 0 ,
																		tailwindPercentage: entry.tailwindPercentage ?? 0,
																		crosswindPercentage: entry.crosswindPercentage ?? 0,
																		cyclingScoreColor: WeatherImpactAnalysisEngine.colorForPercentage(cyclingScore),
																		successfullyFetched: true)
					completion(pathWeatherImpactEntry)
					
				case .failure(_):
					let failurePathWeatherImpactEntry = PathWeatherImpactEntry(date: date, name: "", cyclingScore: 0, message: "Failed to fetch weather data", temperature: 0, windSpeed: 0, headwindPercentage: 0, tailwindPercentage: 0, crosswindPercentage: 0, cyclingScoreColor: .green, successfullyFetched: false)
					completion(failurePathWeatherImpactEntry)
			}
		}
	}
}


//end of provider

struct accessoryCircularWidgetView: View{
	var entry: Provider.Entry
	var body: some View{
		withAnimation {
			HStack{
				Text("\(String(format: "%.f", entry.cyclingScore * 100) )").font(.system(size: 30, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
				+ Text("%").font(.caption).bold().foregroundStyle(.gray)
				
			}
			.contentTransition(.numericText(value:  Double(entry.cyclingScore * 100)))
			
			
		}
		.transition(.push(from: .bottom))
		.animation(.smooth(duration: 2), value: Double(entry.cyclingScore * 100))
	}
}


struct accessoryInlineWidgetView: View {
	var entry: Provider.Entry
	var body: some View {
		Text("\(entry.message)").font(.title)
	}
}

struct accessoryRectangularWidgetView: View {
	var entry: Provider.Entry
	var body: some View {
		HStack{
			Gauge(value: Double(entry.crosswindPercentage)/100){
				Image(systemName: "arrow.down.right.and.arrow.up.left")
			} currentValueLabel: {
				HStack{
					Text("\(entry.crosswindPercentage)%").bold()
				}
				
			}
			.gaugeStyle(.accessoryCircular)
			
			Gauge(value: Double(entry.tailwindPercentage)/100){
				Image(systemName: "arrow.right.to.line")
			} currentValueLabel: {
				HStack{
					Text("\(Int(entry.tailwindPercentage))%").bold()
				}
				
			}
			.gaugeStyle(.accessoryCircular)
			Gauge(value: Double(entry.headwindPercentage)/100){
				Image(systemName: "arrow.left.to.line")
			} currentValueLabel: {
				HStack{
					Text("\(Int(entry.headwindPercentage))%").bold()
				}
				
			}
			.gaugeStyle(.accessoryCircular)
		}
		
		HStack{
			Image(systemName: "gauge.with.dots.needle.bottom.50percent")
			Text("Speeds of ") + Text("\(Int(entry.windSpeed))m/s").bold()
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
		
		VStack(alignment: .leading){
			
			
			withAnimation {
				Text("\(entry.name)").font(.caption)
					.foregroundStyle(.gray)
					.bold()
					.shadow(radius: 20)
			}
			.transition(.push(from: .top))
			.animation(.snappy(duration: 2), value: entry.name)
			
			withAnimation {
				Text("\(entry.date.formatted(date: .omitted, time: .shortened))").font(.caption)
					.foregroundStyle(.gray)
					.bold()
					.shadow(radius: 20)
				
			}
			.transition(.push(from: .top))
			.animation(.snappy(duration: 2), value: entry.date)
			
			
			
			withAnimation {
				HStack{
					Text("\(String(format: "%.f", entry.cyclingScore * 100) )").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
					+ Text("%").font(.caption).bold().foregroundStyle(.gray)
					
				}
				.shadow(radius: 20)
				.contentTransition(.numericText(value:  Double(entry.cyclingScore * 100)))
				
				
			}
			.transition(.push(from: .bottom))
			.animation(.smooth(duration: 2), value: Double(entry.cyclingScore * 100))
			
			
			
			
			withAnimation {
				Gauge(value: Double(entry.windSpeed), in: 0...15){
				} currentValueLabel: {
					HStack{
						Text("\(Int(entry.windSpeed) ) m\\s").bold()
					}
					.contentTransition(.numericText(value: entry.windSpeed))
				}
				.gaugeStyle(.accessoryLinear)
				.tint(windSpeedGradient)
			}
			.transition(.push(from: .bottom))
			.animation(.snappy(duration: 2), value: entry.windSpeed)
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
	let temperatureGradient = Gradient(colors: [ .purple, .blue ,.red])

	
	var body: some View{
		VStack(alignment: .leading){
			
			HStack{
				VStack{
					
					//
					VStack(alignment: .leading) {
						withAnimation {
							Text("\(entry.name)").font(.caption)
								.foregroundStyle(.gray)
								.bold()
								.shadow(radius: 20)
						}
						.transition(.push(from: .top))
						.animation(.snappy(duration: 2), value: entry.name)
						
						withAnimation {
							Text("\(entry.date.formatted(date: .omitted, time: .shortened))").font(.caption)
								.foregroundStyle(.gray)
								.bold()
								.shadow(radius: 20)
							
						}
						.transition(.push(from: .top))
						.animation(.snappy(duration: 2), value: entry.date)
						
					}
					
					// cycling score
					withAnimation {
						HStack{
							Text("\(String(format: "%.f", entry.cyclingScore * 100) )").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
							+ Text("%").font(.caption).bold().foregroundStyle(.gray)
							
						}
						.shadow(radius: 20)
						.padding(.horizontal,20)
						.contentTransition(.numericText(value:  Double(entry.cyclingScore * 100)))
						
						
					}
					.transition(.push(from: .bottom))
					.animation(.smooth(duration: 2), value: Double(entry.cyclingScore * 100))
					
					
				}
				VStack{
					// cycling message
					withAnimation {
						Text(entry.message).font(.caption)
							.foregroundStyle(.gray)
							.bold()
							.shadow(radius: 20)
					}
					.transition(.push(from: .top))
					.animation(.snappy(duration: 2), value: entry.message)
				}
				
				
			}
			
			withAnimation {
				Gauge(value: Double(entry.windSpeed), in: 0...15){
				} currentValueLabel: {
					HStack{
						Text("\(Int(entry.windSpeed) ) m\\s").bold()
							.shadow(radius: 15)
					}
					.contentTransition(.numericText(value: entry.windSpeed))
				}
				.gaugeStyle(.accessoryLinear)
				.tint(windSpeedGradient)
			}
			.transition(.push(from: .bottom))
			.animation(.snappy(duration: 2), value: entry.windSpeed)
			
			
		}
	}
}

struct systemLargeWidgetView: View{
	var entry: Provider.Entry
	let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
	let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
	let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
	let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
	let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
	let temperatureGradient = Gradient(colors: [ .purple, .blue ,.red])

	var body: some View{
		VStack(alignment: .leading){
			
			HStack{
				VStack{
					
					//
					VStack(alignment: .leading) {
						withAnimation {
							Text("\(entry.name)").font(.caption)
								.foregroundStyle(.gray)
								.bold()
								.shadow(radius: 20)
						}
						.transition(.push(from: .top))
						.animation(.snappy(duration: 2), value: entry.name)
						
						withAnimation {
							Text("\(entry.date.formatted(date: .omitted, time: .shortened))").font(.caption)
								.foregroundStyle(.gray)
								.bold()
								.shadow(radius: 20)
							
						}
						.transition(.push(from: .top))
						.animation(.snappy(duration: 2), value: entry.date)
						
					}
					
					// cycling score
					withAnimation {
						HStack{
							Text("\(String(format: "%.f", entry.cyclingScore * 100) )").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
							+ Text("%").font(.caption).bold().foregroundStyle(.gray)
							
						}
						.padding(.horizontal,20)
						.contentTransition(.numericText(value:  Double(entry.cyclingScore * 100)))
						
						
					}
					.transition(.push(from: .bottom))
					.animation(.smooth(duration: 2), value: Double(entry.cyclingScore * 100))
					
					
				}
				VStack{
					// cycling message
					withAnimation {
						Text(entry.message).font(.caption)
							.foregroundStyle(.gray)
							.bold()
							.shadow(radius: 20)
					}
					.transition(.push(from: .top))
					.animation(.snappy(duration: 2), value: entry.message)
				}
				
				
			}
			
			withAnimation {
				Gauge(value: Double(entry.windSpeed), in: 0...15){
				} currentValueLabel: {
					HStack{
						Text("\(Int(entry.windSpeed) ) m\\s").bold()
					}
					.contentTransition(.numericText(value: entry.windSpeed))
				}
				.gaugeStyle(.accessoryLinear)
				.tint(windSpeedGradient)
			}
			.transition(.push(from: .bottom))
			.animation(.snappy(duration: 2), value: entry.windSpeed)
			
			HStack(alignment: .center){
				//temperature gauge
				withAnimation {
					Gauge(value: Double(entry.temperature - 273.15), in: -20...40){
						Image(systemName: "thermometer.medium")
					} currentValueLabel: {
						HStack{
							Text("\(Int(entry.temperature - 273.15))°").bold()
						}.contentTransition(.numericText(value: entry.temperature - 273.15))
						
					}
					.gaugeStyle(.accessoryCircular)
					.tint(temperatureGradient)
					.animation(.spring(duration: 2), value: entry.temperature - 273.15)
				}
				.transition(.push(from: .bottom))
				.animation(.snappy(duration: 2), value: entry.temperature)
				
				//crosswindPercentage gauge
				withAnimation {
					Gauge(value: Double(entry.crosswindPercentage)/100){
						Image(systemName: "arrow.down.right.and.arrow.up.left")
					} currentValueLabel: {
						HStack{
							Text("\(Int(entry.crosswindPercentage))%").bold()
						}.contentTransition(.numericText(value: entry.crosswindPercentage ))
						
					}
					.gaugeStyle(.accessoryCircular)
					.tint(crosswindGradient)
				}
				.transition(.push(from: .bottom))
				.animation(.snappy(duration: 2), value: Double(entry.crosswindPercentage))
				
				//tailwindPercentage gauge
				withAnimation {
					Gauge(value: Double(entry.tailwindPercentage)/100){
						Image(systemName: "arrow.right.to.line")
					} currentValueLabel: {
						HStack{
							Text("\(Int(entry.crosswindPercentage))%").bold()
						}.contentTransition(.numericText(value: entry.crosswindPercentage))
						
					}
					.gaugeStyle(.accessoryCircular)
					.tint(tailwindGradient)
				}
				.transition(.push(from: .bottom))
				.animation(.snappy(duration: 2), value: Double(entry.crosswindPercentage))
				
				//headwindPercentage gauge
				withAnimation {
					Gauge(value: Double(entry.headwindPercentage)/100){
						Image(systemName: "arrow.left.to.line")
					} currentValueLabel: {
						HStack{
							Text("\(Int(entry.headwindPercentage))%").bold()
						}.contentTransition(.numericText(value: entry.headwindPercentage))
						
					}
					.gaugeStyle(.accessoryCircular)
					.tint(headwindGradient)
				}
				.transition(.push(from: .bottom))
				.animation(.snappy(duration: 2), value: Double(entry.headwindPercentage))
				
			}.padding()
				.frame(maxWidth: .infinity)
				
			
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
					.containerBackground(.fill.tertiary.opacity(0.5), for: .widget)
			} else {
				widgetEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("My Widget")
		.description("This is an example widget.")
		.supportedFamilies([.systemSmall, .systemMedium,.systemLarge, .accessoryInline, .accessoryCircular, .accessoryRectangular])
	}
}

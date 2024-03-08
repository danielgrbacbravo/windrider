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
    
    
    @MainActor func placeholder(in context: Context)  -> BikeRouteConditionEntry {
            let route = getFavoriteRoute()
            return BikeRouteConditionEntry(date: Date(), bikeRoute: route)
    }

   @MainActor func getSnapshot(in context: Context, completion: @escaping (BikeRouteConditionEntry)   -> ())  {
           let route =  getFavoriteRoute()
           let entry = BikeRouteConditionEntry(date: Date(), bikeRoute: route )
           completion(entry)
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ())  {
        var entries: [BikeRouteConditionEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
            let route =  getFavoriteRoute()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                
                    
                    let entry = BikeRouteConditionEntry(date: entryDate, bikeRoute: route)
                    entries.append(entry)
            
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
    }
    
    
    @MainActor private func getFavoriteRoute() -> BikeRoute {
        guard let modelContainer = try? ModelContainer(for: BikeRoute.self,BikeRouteCondition.self, BikeRouteCoordinateCondition.self) else {
            return BikeRoute()
        }
        let bikeRouteDescriptor = FetchDescriptor<BikeRoute>()
        
        guard let bikeRoute = try? modelContainer.mainContext.fetch(bikeRouteDescriptor) else {
            return BikeRoute()
        }
        
        bikeRoute[0].fetchAndPopulateBikeRouteConditions(openWeatherMapAPI: OpenWeatherMapAPI(openWeatherMapAPIKey: "22ab22ed87d7cc4edae06caa75c7f449"))
        

        return bikeRoute[0]
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
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    let headwindGradient = Gradient(colors: [.black, .red])
    let crosswindGradient = Gradient(colors: [.black, .orange])
    let tailwindGradient = Gradient(colors: [.black , .green])
    let windSpeedGradient = Gradient(colors: [.green, .yellow, .orange, .red])
    
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
    let headwindGradient = Gradient(colors: [.black, .red])
    let crosswindGradient = Gradient(colors: [.black, .orange])
    let tailwindGradient = Gradient(colors: [.black , .green])
    let windSpeedGradient = Gradient(colors: [.green, .yellow, .orange, .red])
    
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

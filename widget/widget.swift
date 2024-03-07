//
//  widget.swift
//  widget
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import WidgetKit
import SwiftUI
import SwiftData


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
        guard let modelContainer = try? ModelContainer(for: BikeRoute.self) else {
            return BikeRoute()
        }
        let descriptor = FetchDescriptor<BikeRoute>()
        guard let bikeRoute = try? modelContainer.mainContext.fetch(descriptor) else {
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
        
        HStack {
            Image(systemName: "arrow.left.to.line")
            Text("Headwinds: \((entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0).formatted())%").bold()
        }
        
        Gauge(value: Double(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 0)/100){
        }.gaugeStyle(.accessoryLinear)
        
        HStack{
            Image(systemName: "gauge.with.dots.needle.bottom.50percent")
            Text("Speeds of ") + Text("\(entry.bikeRoute.bikeRouteCondition?.windSpeed ?? 0)m/s").bold()
        }
    }
}

struct systemSmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack{
            HStack{
                Text("Headwinds").font(.headline).bold().foregroundStyle(.foreground.opacity(0.9))
                Image(systemName: "arrow.left.to.line").foregroundStyle(.foreground.opacity(0.9))

    
            }
            Text("\(entry.bikeRoute.bikeRouteCondition?.totalHeadwindPercentage ?? 43)%").font(.custom("", size: 60)).bold().foregroundStyle(.orange.opacity(0.8))
        }
    }
}

struct systemMediumWidgetView: View{
    var entry: Provider.Entry
    
    var body: some View{
        VStack{
            
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

#Preview(as: .systemSmall) {
     widget()
 } timeline: {
     BikeRouteConditionEntry(date: .now,bikeRoute: generateSampleRoute())
     BikeRouteConditionEntry(date: .now, bikeRoute: generateSampleRoute())
 }

func generateSampleRoute() -> BikeRoute{
   let points = [Coordinate(latitude: 53.22163,longitude: 6.54162),
                 Coordinate(latitude: 53.22188,longitude: 6.54115),
                 Coordinate(latitude: 53.22214,longitude: 6.54089)]
   let route = BikeRoute(name: "University Route", coordinates:points)
   return route
}

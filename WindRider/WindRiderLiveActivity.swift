//
//  WindRiderLiveActivity.swift
//  WindRider
//
//  Created by Daniel Grbac Bravo on 05/03/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WindRiderAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WindRiderLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WindRiderAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WindRiderAttributes {
    fileprivate static var preview: WindRiderAttributes {
        WindRiderAttributes(name: "World")
    }
}

extension WindRiderAttributes.ContentState {
    fileprivate static var smiley: WindRiderAttributes.ContentState {
        WindRiderAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WindRiderAttributes.ContentState {
         WindRiderAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WindRiderAttributes.preview) {
   WindRiderLiveActivity()
} contentStates: {
    WindRiderAttributes.ContentState.smiley
    WindRiderAttributes.ContentState.starEyes
}

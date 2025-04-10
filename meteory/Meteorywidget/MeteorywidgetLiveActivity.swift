//
//  MeteorywidgetLiveActivity.swift
//  Meteorywidget
//
//  Created by Harsh on 2025-04-07.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MeteorywidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MeteorywidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeteorywidgetAttributes.self) { context in
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

extension MeteorywidgetAttributes {
    fileprivate static var preview: MeteorywidgetAttributes {
        MeteorywidgetAttributes(name: "World")
    }
}

extension MeteorywidgetAttributes.ContentState {
    fileprivate static var smiley: MeteorywidgetAttributes.ContentState {
        MeteorywidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MeteorywidgetAttributes.ContentState {
         MeteorywidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MeteorywidgetAttributes.preview) {
   MeteorywidgetLiveActivity()
} contentStates: {
    MeteorywidgetAttributes.ContentState.smiley
    MeteorywidgetAttributes.ContentState.starEyes
}

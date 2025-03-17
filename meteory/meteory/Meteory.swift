

import SwiftUI
import UIKit

@main
struct MeteoryApp: App {
    @StateObject var colorSchemeManager = ColorSchemeManager()
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(weather: previewData))
                .environmentObject(colorSchemeManager)
                .environmentObject(LocationManager())
        }
    }
}

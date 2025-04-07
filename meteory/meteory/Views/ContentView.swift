import SwiftUI
import CoreLocation
import CoreLocationUI

struct ContentView: View {
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager
    @StateObject var locationManager = LocationManager()
    @StateObject var viewModel: WeatherViewModel
    private var weatherManager = MeteoryManager()
    @State private var weather: ResponseData? = nil
    
    // Public initializer for previews and manual instantiation
    public init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if let userLocation = locationManager.location {
                if let fetched = weather {
                    // Update viewModel with live data and show main view
                    MainView(viewModel: {
                        let vm = viewModel
                        vm.weather = fetched
                        return vm
                    }())
                    .environmentObject(colorSchemeManager)
                } else {
                    LoadingView()
                        .task {
                            do {
                                let fetched = try await weatherManager.getCurrentWeather(
                                    latitude: userLocation.latitude,
                                    longitude: userLocation.longitude
                                )
                                weather = fetched
                            } catch {
                                print("Error getting weather:", error)
                            }
                        }
                }
            } else {
                if locationManager.isLoading {
                    LoadingView()
                        .environmentObject(locationManager)
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                        .environmentObject(colorSchemeManager)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: WeatherViewModel(weather: previewData))
            .environmentObject(ColorSchemeManager())
    }
}

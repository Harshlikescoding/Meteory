import SwiftUI

struct MainView: View {
    @State private var isListVisible: Bool = false
    @State private var isSettingsVisible: Bool = false
    
    @StateObject var viewModel: WeatherViewModel
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Use viewModel.weather directly so that any updates reflect live data
                    WeatherView(viewModel: viewModel)
                        .environmentObject(colorSchemeManager)
                        // Example navigation button showing formatted time using live data
                        .navigationBarItems(leading:
                            Button(action: {}) {
                                Text(viewModel.formatTime(unixTime: Date(), timeZoneOffset: viewModel.weather.city.timezone))
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        )
                        .navigationBarItems(leading:
                            Button(action: {
                                isListVisible.toggle()
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.primary)
                            },
                            trailing: Button(action: {
                                isSettingsVisible.toggle()
                            }) {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.primary)
                            }
                        )
                        .onTapGesture {
                            // Hide sidebars when tapping the main view
                            isSettingsVisible = false
                            isListVisible  = false
                        }
                }
                
                if isListVisible {
                    HStack {
                        LeftSideBarView(viewModel: viewModel)
                            .environmentObject(colorSchemeManager)
                            .frame(width: UIScreen.main.bounds.width * 0.75)
                            .cornerRadius(20)
                            .shadow(radius: 1)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarHidden(true)
                            .transition(.move(edge: .leading))
                        Spacer()
                    }
                }
                
                if isSettingsVisible {
                    HStack {
                        Spacer()
                        RightSideBarView(viewModel: viewModel, isVisible: $isSettingsVisible)
                            .environmentObject(colorSchemeManager)
                            .frame(width: UIScreen.main.bounds.width * 0.75)
                            .cornerRadius(20)
                            .shadow(radius: 1)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarHidden(true)
                            .transition(.move(edge: .trailing))
                    }
                }
            }
            .background(Color(.systemBackground).opacity(0.8))
            .environment(\.colorScheme, colorSchemeManager.currentScheme)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        }
        .onAppear {
            // Fetch live data when the view appears
            viewModel.getWeatherForecast()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: WeatherViewModel(weather: previewData))
            .environmentObject(ColorSchemeManager())
            .environment(\.colorScheme, ColorSchemeManager().currentScheme)
    }
}

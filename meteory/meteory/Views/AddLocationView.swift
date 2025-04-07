

import SwiftUI
import UIKit

struct AddLocationView: View {
    @StateObject var viewModel: WeatherViewModel
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search Location", text: $viewModel.location,
                              onCommit: {
                        viewModel.getWeatherForecast()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .overlay(
                        Button(action: {
                            viewModel.location = ""
                            viewModel.getWeatherForecast()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                            .padding(.horizontal),
                        alignment: .trailing
                    )
                    
                    Button {
                        viewModel.getWeatherForecast()
                        UIApplication.shared.hideKeyboard()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                    }
                }
                
                if !viewModel.location.isEmpty {
                    List([viewModel.weather.city], id: \.name) { cities in
                        Text(cities.name)
                    }
                    .listStyle(.plain)
                }
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .background(Color(.systemBackground).opacity(0.8))
            .foregroundColor(colorSchemeManager.currentScheme == .dark ? .white : .black)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .environment(\.colorScheme, colorSchemeManager.currentScheme)
        }
    }
}



#if compiler(>=5.9)
#Preview {
    AddLocationView(viewModel: WeatherViewModel(weather: previewData))
        .environmentObject(ColorSchemeManager())
        .environment(\.colorScheme, ColorSchemeManager().currentScheme)
}
#else
struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView(viewModel: WeatherViewModel(weather: previewData))
            .environmentObject(ColorSchemeManager())
            .environment(\.colorScheme, ColorSchemeManager().currentScheme)
    }
}
#endif

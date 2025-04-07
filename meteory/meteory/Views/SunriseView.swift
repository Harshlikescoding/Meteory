import SwiftUI

struct SunriseView: View {
    @StateObject var viewModel: WeatherViewModel
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        HStack {
            Text("Sunrise")
                .bold()
            Image(systemName: "sun.max.fill")
                .renderingMode(.original)
            Text(
                formatTime(
                    unixTime: Double(viewModel.weather.city.sunrise),
                    timeZoneOffset: Double(viewModel.weather.city.timezone)
                )
            )
            Spacer()
            Text("Sunset")
                .bold()
            Image(systemName: "moon.fill")
                .foregroundColor(Color("DarkBlue"))
            Text(
                formatTime(
                    unixTime: Double(viewModel.weather.city.sunset),
                    timeZoneOffset: Double(viewModel.weather.city.timezone)
                )
            )
        }
        .font(.body)
        .padding()
        .background(colorSchemeManager.currentScheme == .light
                        ? Color.white
                        : Color(.systemBackground).opacity(0.2))
        .foregroundColor(colorSchemeManager.currentScheme == .dark ? .white : .primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    func formatTime(unixTime: Double, timeZoneOffset: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
}

struct SunriseView_Previews: PreviewProvider {
    static var previews: some View {
        SunriseView(viewModel: WeatherViewModel(weather: previewData))
            .environmentObject(ColorSchemeManager())
    }
}

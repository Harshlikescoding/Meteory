import SwiftUI

struct HourlyForecastView: View {
    let weatherList: ResponseData.ListResponse  // Hourly forecast item from live data
    @ObservedObject var viewModel: WeatherViewModel
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        VStack(spacing: 10) {
            // Use viewModel.weather.city.timezone to get proper local time
            Text(viewModel.formattedHourlyTime(time: weatherList.dt, timeZoneOffset: viewModel.weather.city.timezone))
                .font(.caption2)
            viewModel.weatherIcon(for: weatherList.weather[0].main)
                .renderingMode(.original)
                .shadow(radius: 3)
            Text("\(viewModel.convert(weatherList.main.temp).roundDouble())°")
                .bold()
            HStack(spacing: 5) {
                Image(systemName: "drop.fill")
                    .renderingMode(.original)
                    .foregroundColor(Color("Blue"))
                Text("\(weatherList.main.humidity.roundDouble())%")
            }
            .font(.caption)
        }
        .frame(minWidth: 10, minHeight: 80)
        .padding()
        .background(colorSchemeManager.currentScheme == .light
                        ? Color.white
                        : Color(.systemBackground).opacity(0.2))
        .foregroundColor(colorSchemeManager.currentScheme == .dark ? .white : .primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct HourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
       
        HourlyForecastView(weatherList: previewData.list[0],
                           viewModel: WeatherViewModel(weather: previewData))
            .environmentObject(ColorSchemeManager())
    }
}

import SwiftUI

struct DailyForecastView: View {
    var dailyForecast: WeatherViewModel.DailyForecast
    @ObservedObject var viewModel: WeatherViewModel
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager

    var body: some View {
        HStack {
            // Use the correct helper and pass the Int offset directly
            Text(
                viewModel.formattedDate(
                    from: dailyForecast.day,
                    offset: viewModel.weather.city.timezone
                ) ?? "N/A"
            )
            .font(.caption)
            .bold()

            Spacer()

            HStack {
                viewModel.weatherIcon(for: dailyForecast.main)
                    .renderingMode(.original)
                    .shadow(radius: 5)
                Text(dailyForecast.main)
            }

            Spacer()

            HStack {
                Text("\(viewModel.convert(dailyForecast.maxTemp).roundDouble())°")
                Text("\(viewModel.convert(dailyForecast.minTemp).roundDouble())°")
            }
            .bold()
        }
        .padding()
    }
}

struct DailyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        DailyForecastView(
            dailyForecast: WeatherViewModel.DailyForecast(
                day: "2025-03-17",
                maxTemp: 20,
                minTemp: 14,
                main: "Sunny"
            ),
            viewModel: WeatherViewModel(weather: previewData)
        )
        .environmentObject(ColorSchemeManager())
    }
}

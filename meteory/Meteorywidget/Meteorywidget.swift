import WidgetKit
import SwiftUI

// MARK: — Shared Models & Helpers

/// The data we pass into every widget.
struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: String
    let tempC: Double
    let condition: String
    let daily: [WeatherViewModel.DailyForecast]  // from your view model
}

fileprivate let appGroupID = "group.com.comp3097.meteory"

fileprivate func loadWeather() -> ResponseData? {
    guard
        let defaults = UserDefaults(suiteName: appGroupID),
        let data = defaults.data(forKey: "CachedWeatherData"),
        let weather = try? JSONDecoder().decode(ResponseData.self, from: data)
    else { return nil }
    return weather
}

fileprivate func makeEntry() -> WeatherEntry? {
    guard let w = loadWeather() else { return nil }
    return WeatherEntry(
        date: Date(),
        city: w.city.name,
        tempC: w.list.first?.main.temp ?? 0,
        condition: w.list.first?.weather.first?.main ?? "Clear",
        daily: WeatherViewModel(weather: w).dailyForecasts
    )
}

// MARK: — Helper Functions
func weatherIcon(for condition: String) -> String {
    switch condition {
    case "Clear": return "sun.max.fill"
    case "Clouds": return "cloud.fill"
    case "Rain": return "cloud.rain.fill"
    case "Snow": return "cloud.snow.fill"
    default: return "questionmark"
    }
}

func backgroundImageName(for condition: String) -> String {
    switch condition {
    case "Clear": return "sunny"
    case "Clouds": return "cloudy"
    case "Rain": return "rainy"
    case "Snow": return "snowy"
    default: return "defaultBackground"
    }
}

// MARK: — Current Temperature Widget
struct CurrentProvider: TimelineProvider {
    func placeholder(in ctx: Context) -> WeatherEntry {
        WeatherEntry(date: .now, city: "City", tempC: 0, condition: "Clear", daily: [])
    }
    func getSnapshot(in ctx: Context, completion: @escaping (WeatherEntry) -> ()) {
        completion(makeEntry() ?? placeholder(in: ctx))
    }
    func getTimeline(in ctx: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        let entry = makeEntry() ?? placeholder(in: ctx)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct CurrentView: View {
    var entry: WeatherEntry

    var body: some View {
        VStack {
            Text(entry.city).font(.headline).foregroundColor(.white)
            Text("\(Int(entry.tempC))°C")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            Image(systemName: weatherIcon(for: entry.condition))
                .font(.largeTitle)
                .foregroundColor(.yellow)
        }
        .padding()
        .containerBackground(for: .widget) {
            Image(backgroundImageName(for: entry.condition))
                .resizable()
                .scaledToFill()
        }
    }
}

struct CurrentTempWidget: Widget {
    let kind = "CurrentTempWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrentProvider()) { entry in
            CurrentView(entry: entry)
        }
        .configurationDisplayName("Current Temp")
        .description("Shows the current temperature.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: — Advice Widget
struct AdviceProvider: TimelineProvider {
    func placeholder(in ctx: Context) -> WeatherEntry {
        WeatherEntry(date: .now, city: "City", tempC: 0, condition: "Clear", daily: [])
    }
    func getSnapshot(in ctx: Context, completion: @escaping (WeatherEntry) -> ()) {
        completion(makeEntry() ?? placeholder(in: ctx))
    }
    func getTimeline(in ctx: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        let entry = makeEntry() ?? placeholder(in: ctx)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct AdviceView: View {
    var entry: WeatherEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(Int(entry.tempC))°C")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Text(advice(for: entry.condition, temperature: entry.tempC))
                .font(.caption)
                .padding(.top, 2)
                .foregroundColor(.white)
        }
        .padding()
        .containerBackground(for: .widget) {
            Image(backgroundImageName(for: entry.condition))
                .resizable()
                .scaledToFill()
        }
    }

    func advice(for condition: String, temperature: Double) -> String {
        switch condition {
        case "Rain": return "🌧️ Don't forget your umbrella!"
        case "Snow": return "❄️ Bundle up, it's snowy outside!"
        case "Clear" where temperature > 25: return "☀️ It's hot and sunny! Stay hydrated."
        case "Clear": return "🌞 Enjoy the clear weather!"
        case "Clouds": return "☁️ It's a bit cloudy today."
        default: return "Have a great day!"
        }
    }
}

struct AdviceWidget: Widget {
    let kind = "AdviceWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AdviceProvider()) { entry in
            AdviceView(entry: entry)
        }
        .configurationDisplayName("Weather Advice")
        .description("Gives you tips: umbrella, warm clothes, or sunscreen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: — Daily Forecast Widget
struct DailyProvider: TimelineProvider {
    func placeholder(in ctx: Context) -> WeatherEntry {
        WeatherEntry(date: .now, city: "City", tempC: 0, condition: "Clear", daily: [])
    }
    func getSnapshot(in ctx: Context, completion: @escaping (WeatherEntry) -> ()) {
        completion(makeEntry() ?? placeholder(in: ctx))
    }
    func getTimeline(in ctx: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        let entry = makeEntry() ?? placeholder(in: ctx)
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct DailyView: View {
    var entry: WeatherEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Next Days").font(.headline).foregroundColor(.white)
            ForEach(entry.daily.prefix(4)) { df in
                HStack {
                    Text(df.day).font(.caption2)
                    Spacer()
                    Image(systemName: weatherIcon(for: df.main))
                    Text("\(Int(df.maxTemp))°/ \(Int(df.minTemp))°")
                        .font(.caption2)
                }
                .foregroundColor(.white)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Image(backgroundImageName(for: entry.condition))
                .resizable()
                .scaledToFill()
        }
    }
}

struct DailyForecastWidget: Widget {
    let kind = "DailyForecastWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyProvider()) { entry in
            DailyView(entry: entry)
        }
        .configurationDisplayName("Daily Forecast")
        .description("Shows highs and lows for the next days.")
        .supportedFamilies([.systemMedium])
    }
}



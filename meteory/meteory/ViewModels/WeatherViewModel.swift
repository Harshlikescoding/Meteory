import Foundation
import CoreLocation
import Combine
import SwiftUI

class WeatherViewModel: ObservableObject {
    struct AppError: Identifiable {
        let id = UUID().uuidString
        let errorString: String
    }
    
    @Published var weather: ResponseData
    @Published var isLoading: Bool = false
    @AppStorage("location") var storageLocation: String = "Toronto"
    @Published var location: String = "Toronto"
    @AppStorage("system") var system: Int = 0 {
        didSet { getWeatherForecast() }
    }
    
    var appError: AppError? = nil
    
    init(weather: ResponseData) {
        self.weather = weather
        if location.isEmpty {
            location = "Toronto"
        }
        getWeatherForecast()
    }
    
    // MARK: - Formatters
    
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d/M E"
        return f
    }()
    
    func formattedDate(from dateStr: String, offset: Int) -> String? {
        // dateStr is "yyyy-MM-dd HH:mm:ss" or at least "yyyy-MM-dd"
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = input.date(from: dateStr) else {
            // try fallback if only "yyyy-MM-dd"
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd"
            guard let d2 = fallback.date(from: String(dateStr.prefix(10))) else { return nil }
            return dayFormatter.string(from: d2)
        }
        let f2 = DateFormatter()
        f2.timeZone = TimeZone(secondsFromGMT: offset)
        f2.dateFormat = "d/M E"
        return f2.string(from: date)
    }
    
    func formatTime(unixTime: TimeInterval, offset: Int) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let f = DateFormatter()
        f.timeZone = TimeZone(secondsFromGMT: offset)
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
    
    func formattedHourlyTime(_ unixTime: TimeInterval, offset: Int) -> String {
        formatTime(unixTime: unixTime, offset: offset)
    }
    
    // MARK: - Number Formatters
    
    static var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }
    
    static var percentFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        nf.maximumFractionDigits = 0
        return nf
    }
    
    // MARK: - Converters
    
    func convert(_ temp: Double) -> Double {
        if system == 0 {
            return temp
        } else {
            return temp * 9 / 5 + 32
        }
    }
    
    func weatherIcon(for condition: String) -> Image {
        switch condition {
        case "Clear": return Image(systemName: "sun.max.fill")
        case "Clouds": return Image(systemName: "cloud.fill")
        case "Rain": return Image(systemName: "cloud.rain.fill")
        case "Snow": return Image(systemName: "cloud.snow.fill")
        default: return Image(systemName: "questionmark")
        }
    }
    
    // MARK: - Current Weather Properties
    
    var name: String { weather.city.name }
    var overview: String { weather.list.first?.weather.first?.description.capitalized ?? "" }
    var temperature: String {
        let temp = weather.list.first?.main.temp ?? 0
        return "\(Self.numberFormatter.string(for: convert(temp)) ?? "0")°"
    }
    var high: String {
        let t = weather.list.first?.main.tempMax ?? 0
        return "H: \(Self.numberFormatter.string(for: convert(t)) ?? "0")°"
    }
    var low: String {
        let t = weather.list.first?.main.tempMin ?? 0
        return "L: \(Self.numberFormatter.string(for: convert(t)) ?? "0")°"
    }
    var feels: String {
        let t = weather.list.first?.main.feelsLike ?? 0
        return "\(Self.numberFormatter.string(for: convert(t)) ?? "0")°"
    }
    var pop: String {
        let p = weather.list.first?.pop ?? 0
        return Self.percentFormatter.string(for: p) ?? "0%"
    }
    var main: String {
        weather.list.first?.weather.first?.main ?? ""
    }
    var clouds: String {
        "\(weather.list.first?.clouds.all ?? 0)%"
    }
    var humidity: String {
        "\(weather.list.first?.main.humidity ?? 0)%"
    }
    var wind: String {
        let s = weather.list.first?.wind.speed ?? 0
        return "\(Self.numberFormatter.string(for: s) ?? "0") m/s"
    }
    
    // MARK: - Daily Forecast
    
    public struct DailyForecast: Identifiable {
        public let id = UUID()
        let day: String        // "yyyy-MM-dd HH:mm:ss"
        let maxTemp: Double
        let minTemp: Double
        let main: String
    }
    
    public var dailyForecasts: [DailyForecast] {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let todayStr = f.string(from: today)

        // Group by date string—prefer dtTxt, fallback to localTime, or format dt.
        let grouped = Dictionary(grouping: weather.list) { item -> String in
            if let txt = item.dtTxt {
                return String(txt.prefix(10))
            } else if let lt = item.localTime {
                return String(lt.prefix(10))
            } else {
                let date = Date(timeIntervalSince1970: item.dt)
                return f.string(from: date)
            }
        }

        let keys = grouped.keys.sorted()
        // If today beyond forecast range, return all
        if let last = keys.last, todayStr > last {
            return keys.compactMap { dateKey in
                guard let vals = grouped[dateKey],
                      let max = vals.max(by: { $0.main.tempMax < $1.main.tempMax }),
                      let min = vals.min(by: { $0.main.tempMin < $1.main.tempMin })
                else { return nil }
                return DailyForecast(day: dateKey,
                                     maxTemp: max.main.tempMax,
                                     minTemp: min.main.tempMin,
                                     main: max.weather.first?.main ?? "")
            }
        }

        // Otherwise start from tomorrow
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
            return []
        }
        let tomorrowStr = f.string(from: tomorrow)
        return keys.filter { $0 >= tomorrowStr }.compactMap { dateKey in
            guard let vals = grouped[dateKey],
                  let max = vals.max(by: { $0.main.tempMax < $1.main.tempMax }),
                  let min = vals.min(by: { $0.main.tempMin < $1.main.tempMin })
            else { return nil }
            return DailyForecast(day: dateKey,
                                 maxTemp: max.main.tempMax,
                                 minTemp: min.main.tempMin,
                                 main: max.weather.first?.main ?? "")
        }
    }

    
    // MARK: - Caching & Fetching
    
    func cacheWeatherData() {
        if let data = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(data, forKey: "CachedWeatherData")
        }
    }
    
    func loadCachedWeatherData() {
        if let data = UserDefaults.standard.data(forKey: "CachedWeatherData"),
           let decoded = try? JSONDecoder().decode(ResponseData.self, from: data) {
            DispatchQueue.main.async {
                self.weather = decoded
            }
        }
    }
    
    func getWeatherForecast() {
        storageLocation = location
        isLoading = true
        
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            if let err = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.appError = AppError(errorString: err.localizedDescription)
                }
                return
            }
            guard let coord = placemarks?.first?.location?.coordinate else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.appError = AppError(errorString: "Unable to geocode location.")
                }
                return
            }
            
            Task {
                do {
                    let mgr = MeteoryManager()
                    let resp = try await mgr.getCurrentWeather(
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                    DispatchQueue.main.async {
                        self.weather = resp
                        self.isLoading = false
                        self.cacheWeatherData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.appError = AppError(errorString: error.localizedDescription)
                        self.loadCachedWeatherData()
                    }
                }
            }
        }
    }
}

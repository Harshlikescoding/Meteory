import Foundation
import CoreLocation
import Combine
import SwiftUI

private let apiKey = "0cc5fa34d6cc7af0300b1e67cd71f082"

class WeatherViewModel: ObservableObject {
    struct AppError: Identifiable {
        let id = UUID().uuidString
        let errorString: String
    }
    
    var appError: AppError? = nil
    
    @Published var weather: ResponseData
    @Published var isLoading: Bool = false
    @AppStorage("location") var storageLocation: String = "Toronto"
    @Published var location = "Toronto"
    @AppStorage("system") var system: Int = 0 {
        didSet { getWeatherForecast() }
    }
    
    init(weather: ResponseData) {
        self.weather = weather
        // Ensure there is a default location
        if location.isEmpty {
            location = "Toronto"
        }
        getWeatherForecast()
    }
    
    let weeklyDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M E"
        return formatter
    }()
    
    func formattedTime(from string: String, timeZoneOffset: Double) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "YY/MM/dd"
        if let date = inputFormatter.date(from: string) {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
            return weeklyDay.string(from: date)
        }
        return nil
    }
    
    func formatTime(unixTime: Date, timeZoneOffset: Double) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d, MMM"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: unixTime)
    }
    
    func formattedHourlyTime(time: Double, timeZoneOffset: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
    
    static var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }
    
    static var numberFormatter2: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        return nf
    }
    
    func convert(_ temp: Double) -> Double {
        let celsius = temp - 273.5
        return system == 0 ? celsius : (celsius * 9 / 5 + 32)
    }
    
    func weatherIcon(for condition: String) -> Image {
        switch condition {
        case "Clear":
            return Image(systemName: "sun.max.fill")
        case "Clouds":
            return Image(systemName: "cloud.fill")
        case "Rain":
            return Image(systemName: "cloud.rain.fill")
        case "Snow":
            return Image(systemName: "cloud.snow.fill")
        default:
            return Image(systemName: "questionmark")
        }
    }
    
    var name: String { weather.city.name }
    var day: String { weeklyDay.string(from: Date(timeIntervalSince1970: weather.list[0].dt)) }
    var overview: String { weather.list[0].weather[0].description.capitalized }
    
    var temperature: String {
        "\(Self.numberFormatter.string(for: convert(weather.list[0].main.temp)) ?? "0")°"
    }
    
    var high: String {
        "H: \(Self.numberFormatter.string(for: convert(weather.list[0].main.tempMax)) ?? "0")°"
    }
    
    var low: String {
        "L: \(Self.numberFormatter.string(for: convert(weather.list[0].main.tempMin)) ?? "0")°"
    }
    
    var feels: String {
        "\(Self.numberFormatter.string(for: convert(weather.list[0].main.feelsLike)) ?? "0")°"
    }
    
    var pop: String {
        "\(Self.numberFormatter2.string(for: weather.list[0].pop.roundDouble()) ?? "0%")"
    }
    
    var main: String {
        "\(weather[0].weather[0].main)"
    }
    
    var clouds: String {
        "\(weather.list[0].clouds)%"
    }
    
    var humidity: String {
        "\(weather.list[0].main.humidity.roundDouble())%"
    }
    
    var wind: String {
        "\(Self.numberFormatter.string(for: weather.list[0].wind.speed) ?? "0")m/s"
    }
    
    public struct DailyForecast {
        let day: String
        let maxTemp: Double
        let minTemp: Double
        let main: String
    }
    
    // Updated dailyForecasts property: only include days after today.
    public var dailyForecasts: [DailyForecast] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        // Group forecast items by date (first 10 characters of localTime)
        let groupedData = Dictionary(grouping: weather.list) { element -> String in
            let dateStr = String(element.localTime.prefix(10))
            return dateStr
        }
        
        // Filter out today; only include dates greater than today's date.
        let filteredData = groupedData.filter { key, _ in key > todayStr }
        
        return filteredData.compactMap { (key, values) in
            guard let maxTemp = values.max(by: { $0.main.tempMax < $1.main.tempMax }),
                  let minTemp = values.min(by: { $0.main.tempMin < $1.main.tempMin }) else {
                return nil
            }
            return DailyForecast(day: key,
                                 maxTemp: maxTemp.main.tempMax,
                                 minTemp: minTemp.main.tempMin,
                                 main: maxTemp.weather[0].main)
        }
    }
    
    // MARK: - Caching & Live Data Fetching
    
    func cacheWeatherData() {
        if let encoded = try? JSONEncoder().encode(self.weather) {
            UserDefaults.standard.set(encoded, forKey: "CachedWeatherData")
        }
    }
    
    func loadCachedWeatherData() {
        if let savedData = UserDefaults.standard.data(forKey: "CachedWeatherData"),
           let decoded = try? JSONDecoder().decode(ResponseData.self, from: savedData) {
            DispatchQueue.main.async {
                self.weather = decoded
            }
        } else {
            print("No cached data found.")
        }
    }
    
    func getWeatherForecast() {
        storageLocation = location
        isLoading = true
        let apiService = APIService.shared
        
        // Geocode the address string to get coordinates.
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.appError = AppError(errorString: error.localizedDescription)
                    print("Geocoding error:", error.localizedDescription)
                }
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                let urlString = "https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)&units=metric"
                apiService.getJSON(urlString: urlString, dateDecodingStrategy: .secondsSince1970) { (result: Result<ResponseData, APIService.APIError>) in
                    switch result {
                    case .success(let weather):
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.weather = weather
                            self.cacheWeatherData()
                        }
                    case .failure(let apiError):
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.appError = AppError(errorString: "\(apiError)")
                            print("API Error:", apiError)
                            self.loadCachedWeatherData()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.appError = AppError(errorString: "Unable to determine coordinates for the location.")
                }
            }
        }
    }
}


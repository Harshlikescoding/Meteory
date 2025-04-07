import Foundation
import CoreLocation

private let apiKey = "9dcb14f2ca6aff278d277a00530fa7bb"

class MeteoryManager {
    /// Fetches the free 5‑day/3‑hour forecast.
    func getCurrentWeather(latitude: CLLocationDegrees,
                           longitude: CLLocationDegrees) async throws -> ResponseData {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "MeteoryManager", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "MeteoryManager", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(code)"])
        }
        // Debug raw JSON
        if let raw = String(data: data, encoding: .utf8) {
            print("Raw JSON Response:\n\(raw)")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        let resp = try decoder.decode(ResponseData.self, from: data)
        print("Decoded ResponseData:", resp)
        return resp
    }
}

/// Top‑level response.
struct ResponseData: Codable, Identifiable {
    var id: UUID { UUID() }
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ListResponse]
    let city: CityResponse
}

/// Each 3‑hour forecast entry.
struct ListResponse: Codable, Identifiable {
    var id: Double { dt }
    
    let dt: Double
    let main: MainResponse
    let weather: [WeatherResponse]
    let clouds: CloudsResponse
    let wind: WindResponse
    let visibility: Int?
    let pop: Double
    let sys: SysResponse
    
    /// From `"dt_txt"` in JSON.
    let dtTxt: String?
    /// From `"localTime"` in preview JSON.
    let localTime: String?
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys
        case dtTxt    = "dt_txt"
        case localTime
    }
}

struct MainResponse: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let seaLevel: Int
    let grndLevel: Int
    let humidity: Int
    let tempKf: Double
}

struct WeatherResponse: Codable, Identifiable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct CloudsResponse: Codable {
    let all: Int
}

struct WindResponse: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct SysResponse: Codable {
    let pod: String
}

struct CityResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let coord: CoordResponse
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

struct CoordResponse: Codable {
    let lat: Double
    let lon: Double
}

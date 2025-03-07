import SwiftUI

struct WeatherDashboard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var cityName: String = "New York"
    @State private var temperature: Int = 72
    @State private var feelsLike: Int = 70
    @State private var weatherCondition: String = "Sunny"
    @State private var humidity: Int = 55
    @State private var windSpeed: Int = 12
    @State private var uvIndex: Int = 5
    @State private var airQuality: Int = 50 // AQI scale 0-500
    @State private var sunriseTime: String = "6:30 AM"
    @State private var sunsetTime: String = "6:45 PM"

    @State private var savedLocations: [String] = UserDefaults.standard.array(forKey: "savedCities") as? [String] ?? ["New York", "Los Angeles"]

    @State private var showMenu = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // ✅ 7-Day Forecast Data
    @State private var weeklyForecast: [(String, String, Int, Int, Int, Int)] = []

    var body: some View {
        ZStack {
            backgroundView()
                .edgesIgnoringSafeArea(.all)
                .preferredColorScheme(isDarkMode ? .dark : .light)

            VStack {
                // ✅ Header: Side Menu Button
                HStack {
                    Button(action: {
                        withAnimation(.spring()) { showMenu.toggle() }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    Spacer()
                }
                .padding()

                // ✅ City Name & Weather Condition
                Text(cityName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text(weatherCondition)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                // ✅ Temperature Display
                VStack {
                    Image(systemName: getWeatherIcon(condition: weatherCondition))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.yellow)

                    Text("\(temperature)°")
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    Text("Feels like \(feelsLike)°")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                        .padding(.top, 2)
                }
                .padding()

                // ✅ Weather Details Section
                VStack(spacing: 10) {
                    WeatherDetailRow(icon: "wind", title: "Wind Speed", value: "\(windSpeed) km/h")
                    WeatherDetailRow(icon: "sun.max", title: "UV Index", value: "\(uvIndex) - \(uvRiskLevel())", color: uvRiskColor())
                    WeatherDetailRow(icon: "aqi.medium", title: "Air Quality", value: "\(airQuality) - \(airQualityDescription())", color: airQualityColor())
                    WeatherDetailRow(icon: "sunrise.fill", title: "Sunrise", value: sunriseTime)
                    WeatherDetailRow(icon: "sunset.fill", title: "Sunset", value: sunsetTime)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()

                Spacer()
            }
            .padding()
            .onAppear {
                generateWeeklyForecast()
            }

            // ✅ Overlay Side Menu (Appears on Top)
            SideMenuView(
                showMenu: $showMenu,
                cityName: $cityName,
                temperature: $temperature,
                savedLocations: $savedLocations,
                colorScheme: colorScheme,
                updateForecast: updateWeather
            )
        }
    }
    func generateWeeklyForecast() {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let weatherIcons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.bolt.rain.fill", "cloud.rain.fill", "wind", "cloud.drizzle.fill"]

        weeklyForecast = days.map { day in
            let icon = weatherIcons.randomElement() ?? "cloud.fill"
            let highTemp = Int.random(in: 25...40)
            let lowTemp = highTemp - Int.random(in: 5...15)
            let wind = Int.random(in: 10...30)
            let humidity = Int.random(in: 40...90)

            return (day, icon, highTemp, lowTemp, wind, humidity)
        }
    }
    // ✅ Refresh Weather on City Change
    func updateWeather() {
        temperature = Int.random(in: 50...90)
        weatherCondition = ["Sunny", "Cloudy", "Rainy"].randomElement() ?? "Sunny"
        feelsLike = temperature - Int.random(in: 0...5)
        humidity = Int.random(in: 40...90)
        windSpeed = Int.random(in: 5...20)
        uvIndex = Int.random(in: 0...10)
        airQuality = Int.random(in: 10...300)
    }

    // ✅ Background Gradient Based on Weather & Time
    func backgroundView() -> LinearGradient {
        let hour = Calendar.current.component(.hour, from: Date())
        let colors: [Color]

        if isDarkMode {
            colors = [.black, .gray]
        } else {
            switch weatherCondition {
            case "Sunny":
                colors = hour < 18 ? [.blue, .yellow] : [.purple, .orange]
            case "Cloudy":
                colors = [.gray, .white]
            case "Rainy":
                colors = [.blue, .gray]
            default:
                colors = [.blue, .white]
            }
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    // ✅ Weather Icon Mapping
    func getWeatherIcon(condition: String) -> String {
        switch condition {
        case "Sunny": return "sun.max.fill"
        case "Cloudy": return "cloud.fill"
        case "Rainy": return "cloud.rain.fill"
        default: return "sun.max.fill"
        }
    }

    // ✅ UV Risk Level Helpers
    func uvRiskLevel() -> String {
        switch uvIndex {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }

    func uvRiskColor() -> Color {
        switch uvIndex {
        case 0...2: return .green
        case 3...5: return .yellow
        case 6...7: return .orange
        case 8...10: return .red
        default: return .purple
        }
    }

    // ✅ Air Quality Helpers
    func airQualityDescription() -> String {
        switch airQuality {
        case 0...50: return "Good"
        case 51...100: return "Moderate"
        case 101...150: return "Unhealthy (Sensitive)"
        case 151...200: return "Unhealthy"
        case 201...300: return "Very Unhealthy"
        default: return "Hazardous"
        }
    }

    func airQualityColor() -> Color {
        switch airQuality {
        case 0...50: return .green
        case 51...100: return .yellow
        case 101...150: return .orange
        case 151...200: return .red
        case 201...300: return .purple
        default: return .black
        }
    }
}

struct WeatherDetailRow: View {
    var icon: String
    var title: String
    var value: String
    var color: Color = .white

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.white.opacity(0.1)) // Added better contrast
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

import SwiftUI

struct WeatherDashboard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var cityName: String = "New York"
    @State private var temperature: Int = 72
    @State private var feelsLike: Int = 30
    @State private var weatherCondition: String = "Sunny"
    @State private var humidity: Int = 55
    @State private var windSpeed: Int = 12
    @State private var uvIndex: Int = 5
    @State private var airQuality: Int = 50
    @State private var sunriseTime: String = "6:30 AM"
    @State private var sunsetTime: String = "6:45 PM"
    @State private var hourlyForecast: [(String, String, Int)] = []

    @State private var savedLocations: [String] = UserDefaults.standard.array(forKey: "savedCities") as? [String] ?? ["New York", "Los Angeles"]
    @State private var showMenu = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var weeklyForecast: [(String, String, Int, Int, Int, Int)] = []

    var body: some View {
        ScrollView {
            ZStack {
                backgroundView()
                    .edgesIgnoringSafeArea(.all)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                if showMenu {
                                SideMenuView(
                                    showMenu: $showMenu,
                                    cityName: $cityName,
                                    temperature: $temperature,
                                    savedLocations: $savedLocations,
                                    colorScheme: colorScheme,
                                    updateForecast: generateWeeklyForecast
                                )
                                .zIndex(1)
                            }
                
                VStack {
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
                    
                    Text(cityName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text(weatherCondition)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
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
                    
                    
                    
                    Spacer()
                    Text("Hourly Forecast")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(hourlyForecast, id: \.0) { hour, icon, temp in
                                HourlyWeatherBox(hour: hour, icon: icon, temperature: temp)
                            }
                        }
                        .padding(.horizontal)
                    }

                    VStack {
                        Text("7-Day Forecast")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)

                        ForEach(weeklyForecast, id: \.0) { day, icon, highTemp, lowTemp, wind, humidity in
                            HStack {
                                Text(day)
                                    .font(.headline)
                                    .frame(width: 80, alignment: .leading)
                                
                                Image(systemName: icon)
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                
                                Spacer()
                                
                                Text("\(highTemp)° / \(lowTemp)°")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("💨\(wind) km/h")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("💧\(humidity)%")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                            
                            Text("Weather Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.top)

                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                WeatherSquare(icon: "wind", title: "Wind", value: "\(windSpeed) km/h", color: .blue)
                                WeatherSquare(icon: "sun.max", title: "UV Index", value: "\(uvIndex)", color: uvRiskColor())
                                WeatherSquare(icon: "aqi.medium", title: "Air Quality", value: "\(airQuality)", color: airQualityColor())
                                WeatherSquare(icon: "sunrise.fill", title: "Sunrise", value: sunriseTime, color: .orange)
                                WeatherSquare(icon: "sunset.fill", title: "Sunset", value: sunsetTime, color: .purple)
                            }
                            .padding()

                        
                    }
                    .padding()
                }
                .padding()
                .onAppear {
                    generateWeeklyForecast()
                    generateHourlyForecast()
                        

                }
            }
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

    func getWeatherIcon(condition: String) -> String {
        switch condition {
        case "Sunny": return "sun.max.fill"
        case "Cloudy": return "cloud.fill"
        case "Rainy": return "cloud.rain.fill"
        default: return "sun.max.fill"
        }
    }

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
    func generateHourlyForecast() {
        let hours = ["Now", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM"]
        let weatherIcons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.bolt.rain.fill", "cloud.rain.fill"]
        
        hourlyForecast = hours.map { hour in
            let icon = weatherIcons.randomElement() ?? "cloud.fill"
            let temp = Int.random(in: 20...35) // Generate random temperatures
            return (hour, icon, temp)
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
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
struct WeatherSquare: View {
    var icon: String
    var title: String
    var value: String
    var color: Color

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 120, height: 120)
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
struct HourlyWeatherBox: View {
    var hour: String
    var icon: String
    var temperature: Int

    var body: some View {
        VStack {
            Text(hour)
                .font(.headline)
                .foregroundColor(.white)
            
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.yellow)
            
            Text("\(temperature)°")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 100) 
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

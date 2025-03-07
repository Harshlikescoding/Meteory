import SwiftUI

struct SideMenuView: View {
    @Binding var showMenu: Bool
    @Binding var cityName: String
    @Binding var temperature: Int
    @Binding var savedLocations: [String]
    var colorScheme: ColorScheme
    var updateForecast: () -> Void

    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var searchText = ""

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .leading) {
                // ✅ Dimmed background when menu is open
                if showMenu {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showMenu = false }
                        }
                }

                // ✅ Side Menu Content
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Menu")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                        Button(action: {
                            withAnimation { showMenu = false }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .padding(.top, 50)

                    Divider().background(Color.white.opacity(0.5))

                    // ✅ Dark Mode Toggle
                    HStack {
                        Text("Dark Mode")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .font(.title)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .padding()

                    Divider().background(Color.white.opacity(0.5))

                    // ✅ City Selector
                    Text("Select a City")
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom, 5)

                    ScrollView {
                        ForEach(savedLocations, id: \.self) { city in
                            Button(action: {
                                cityName = city
                                temperature = Int.random(in: 20...30) // ✅ Simulating different temperatures
                                updateForecast() // ✅ Refresh the forecast
                                withAnimation { showMenu = false }
                            }) {
                                HStack {
                                    Text(city)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .padding()
                                    Spacer()
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }

                    Divider().background(Color.white.opacity(0.5))

                    // ✅ Search & Add City
                    HStack {
                        TextField("Search City", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: {
                            if !searchText.isEmpty {
                                savedLocations.append(searchText)
                                cityName = searchText
                                temperature = Int.random(in: 15...35) // ✅ Assigning a random temperature
                                searchText = ""
                                UserDefaults.standard.set(savedLocations, forKey: "savedCities")
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()
                .frame(width: 250)
                .background(Color.blue.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .offset(x: showMenu ? 0 : -250)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: showMenu) // ✅ Smooth animation
            }
        }
    }
}

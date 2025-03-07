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
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                if showMenu {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showMenu = false }
                        }
                }

            
                ZStack {
                
                    (colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                        .edgesIgnoringSafeArea(.all)

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

                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Add a City")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)

                            HStack {
                                TextField("Enter city name", text: $searchText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(8)

                                Button(action: {
                                    if !searchText.isEmpty {
                                        
                                        if !savedLocations.contains(searchText) {
                                            savedLocations.append(searchText)
                                            UserDefaults.standard.set(savedLocations, forKey: "savedCities")
                                        }
                                        cityName = searchText
                                        temperature = Int.random(in: 15...35)
                                        updateForecast()
                                        searchText = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()

                        Divider().background(Color.white.opacity(0.5))

                        
                        Text("Select a City")
                            .font(.title2)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.bottom, 5)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(savedLocations, id: \.self) { city in
                                    Button(action: {
                                        cityName = city
                                        temperature = Int.random(in: 20...30)
                                        updateForecast()
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
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .frame(maxHeight: geometry.size.height * 0.4) 

                        Spacer()
                    }
                    .padding()
                }
                .frame(width: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .offset(x: showMenu ? 0 : -250)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: showMenu)
            }
        }
    }
}

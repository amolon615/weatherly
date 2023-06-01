
import SwiftUI

struct ContentView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    @StateObject var locationDataManager = LocationManager()
    @State var cityName: String = "Lyon"
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5).ignoresSafeArea()
            VStack {
                HStack (spacing: 15) {
                    TextField("City name", text: $cityName)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.leading)
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .padding(.trailing)
                        .onTapGesture {
                            Task {
                                locationDataManager.requestAuthorization()
                                locationDataManager.fetchCityLocation(cityName: "\($cityName)") { result in
                                    switch result {
                                    case .success(let location):
                                        print("Latitude: \(location.latitude)")
                                        print("Longitude: \(location.longitude)")
                                        Task {
                                            await weatherKitManager.getWeather(latitude: location.latitude, longitude: location.longitude)
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }
                   
                }
                .frame(width: 330, height: 100)
                
                VStack {
                    Text(weatherKitManager.temp)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                    
                    Image(systemName: weatherKitManager.symbol)
                    .font(.system(size: 60, weight: .semibold, design: .rounded))
                }
                .frame(width: 300, height: 300)
                .background(Color.blue.opacity(0.3))
                .cornerRadius(20)
                    
            }.task {
                    locationDataManager.requestAuthorization()
                locationDataManager.fetchCityLocation(cityName: "\($cityName)") { result in
                    switch result {
                    case .success(let location):
                        print("Latitude: \(location.latitude)")
                        print("Longitude: \(location.longitude)")
                        Task {
                            await weatherKitManager.getWeather(latitude: location.latitude, longitude: location.longitude)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

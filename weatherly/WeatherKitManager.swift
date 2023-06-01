
import SwiftUI
import WeatherKit


@MainActor class WeatherKitManager: ObservableObject {
    @Published var weather: Weather?
    
    func getWeather(latitude: Double, longitude: Double) async {
        do {
            weather = try await Task.detached(priority: .userInitiated) {
                return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
            }.value
        } catch {
            fatalError("\(error)")
        }
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? "xmark"
    }
    
    
    
    var temp: String {
        let temp =
        weather?.currentWeather.temperature
        
        return temp?.description ?? "Loading Weather Data"
        
    }
    
    
    var dailyForecast:  Forecast<DayWeather>? {
       var daily =  weather?.dailyForecast
        return daily
    }
    
    
}

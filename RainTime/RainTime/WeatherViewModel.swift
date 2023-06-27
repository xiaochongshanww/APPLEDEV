//
//  WeatherViewModel.swift
//  RainTime
//
//  Created by 青云子 on 2023/6/27.
//

import Foundation

import SwiftUI

import SwiftUI

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String = ""

    func fetchWeatherData(for city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=YOUR_API_KEY") else {
            errorMessage = "Invalid URL"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            guard let data = data else {
                self.errorMessage = "No data received"
                return
            }

            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                self.weatherData = weatherResponse.toWeatherData()
                self.errorMessage = ""
            } catch {
                self.errorMessage = "Failed to decode weather data"
            }
        }

        task.resume()
    }
}


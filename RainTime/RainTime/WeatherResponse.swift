//
//  WeatherResponse.swift
//  RainTime
//
//  Created by 青云子 on 2023/6/27.
//

import Foundation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    // 其他相关属性

    struct Main: Codable {
        let temp: Double
        // 其他相关属性
    }

    struct Weather: Codable {
        let main: String
        let description: String
        // 其他相关属性
    }

    struct Wind: Codable {
        let speed: Double
        // 其他相关属性
    }

    // 将 WeatherResponse 转换为 WeatherData 的方法
    func toWeatherData() -> WeatherData {
        let city = "" // 根据 API 数据中的城市字段获取城市名称
        let temperature = main.temp // 根据 API 数据中的温度字段获取温度值
        let condition = weather.first?.main ?? "" // 根据 API 数据中的天气字段获取天气状况
        let windSpeed = wind.speed // 根据 API 数据中的风速字段获取风速值

        return WeatherData(city: city, temperature: temperature, condition: condition, windSpeed: windSpeed)
    }
}

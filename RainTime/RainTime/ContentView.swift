//
//  ContentView.swift
//  RainTime
//
//  Created by 青云子 on 2023/6/27.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct WeatherView: View {
    var cityName: String
    var weather: String
    var temperature: String
    var poem: String

    var body: some View {
        VStack {
            Text(cityName)
                .font(.system(size: 32, weight: .medium, design: .default))
            Spacer()
            HStack {
                Text(weather)
                    .font(.system(size: 24, weight: .light, design: .default))
                Text(temperature)
                    .font(.system(size: 24, weight: .light, design: .default))
            }
            Spacer()
            Text(poem)
                .font(.system(size: 20, weight: .light, design: .default))
                .padding()
            Spacer()
        }
    }
}

struct ContentView: View {
    @State private var poem = "细雨鱼儿出，微风燕子斜。"

    var body: some View {
        NavigationView {
            VStack {
                TabView {
                    WeatherView(cityName: "城市1", weather: "晴朗", temperature: "24°C", poem: poem)
                        .tag(0)
                    WeatherView(cityName: "城市2", weather: "多云", temperature: "22°C", poem: poem)
                        .tag(1)
                    WeatherView(cityName: "城市3", weather: "阴天", temperature: "20°C", poem: poem)
                        .tag(2)
                    // 添加更多的城市...
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack {
                    Spacer()
                    Button(action: {
                        print("Menu button pressed.")
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Weather", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}











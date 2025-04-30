//
//  WeatherData.swift
//  Weatherly
//
//  Created by Manoj Aryal on 5/16/21.
//

import Foundation
import CoreLocation


protocol WeatherDelegate {
    func didUpdateWeather(_ weatherInfo: WeatherInfo, weather: WeatherModel)
    func didFailedWithError(error: Error)
}


struct WeatherInfo {
    let url = "https://api.openweathermap.org/data/2.5/weather?appid={your-api-key}&units=imperial"
    
    var delegate: WeatherDelegate?
    
    func getWeather(cityName: String){
        let urlString = "\(url)&q=\(cityName)";
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        request(with: url!)
    }
    
    func getWeatherWithCoord(latitude: CLLocationDegrees, longitude:CLLocationDegrees){
        let urlString = "\(url)&lat=\(latitude)&lon=\(longitude)";
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print(url!)
        request(with: url!)
    }
    
    func request(with currURL: String){
        if let url = URL(string: currURL){
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailedWithError(error: error!)
                    return
                }
                
                if let currData = data {
                    if let weather = self.parseJSON(currData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = String(format: "%.1f", decodedData.main.temp)
            let name = decodedData.name
            
            let weather = WeatherModel(cityName: name, weatherId: id, temp: temp)
            return weather
            
        } catch {
            self.delegate?.didFailedWithError(error: error)
            return nil
        }
        
    }
    
}


struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}


struct Main: Codable {
    let temp: Double
}


struct Weather: Codable {
    let description: String
    let id: Int
}


struct WeatherModel {
    
    let cityName: String
    let weatherId: Int
    let temp: String
    
    var ConditionName: String {
        switch weatherId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}

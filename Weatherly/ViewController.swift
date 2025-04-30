//
//  ViewController.swift
//  weatherly
//
//  Created by Manoj Aryal on 5/15/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    var weatherData = WeatherInfo()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
       
        weatherData.delegate = self
        searchField.delegate = self
    }
    
    @IBAction func currLocationButton(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}


extension ViewController: UITextFieldDelegate {
    
    @IBAction func searched(_ sender: UIButton) {
        searchField.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Please type something!"
            return false
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchField.text{
            weatherData.getWeather(cityName: city)
        }
        searchField.text = ""
    }
}


extension ViewController: WeatherDelegate {
    func didUpdateWeather(_ weatherInfo: WeatherInfo, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temp.text = weather.temp
            self.icon.image = UIImage(systemName:weather.ConditionName)
            self.city.text = weather.cityName
        }
    }
    
    func didFailedWithError(error: Error) {
        print(error)
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            weatherData.getWeatherWithCoord(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

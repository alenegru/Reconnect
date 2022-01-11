//
//  WeatherViewController.swift
//  Reconnect
//
//  Created by Danciu Vasi on 06/12/2021.
//


import UIKit
import CoreLocation
import JGProgressHUD

class WeatherViewController: UIViewController {
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        if (UserDefaults.standard.value(forKey: "lat") == nil && UserDefaults.standard.value(forKey: "long") == nil) {
            spinner.show(in: view)
        } else {
            temperatureLabel.text = UserDefaults.standard.value(forKey: "tempLabel") as? String
            conditionImageView.image = UIImage(systemName: UserDefaults.standard.value(forKey: "conditionImage") as! String)
        }
        
        weatherManager.delegate = self
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("ceva")
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            UserDefaults.standard.setValue(lat, forKey: "lat")
            UserDefaults.standard.setValue(long, forKey: "long")
            
            weatherManager.fetchWeather(latitude: lat, longitude: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("altceva")
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        UserDefaults.standard.setValue(46.7667, forKey: "lat")
        UserDefaults.standard.setValue(23.6, forKey: "long")
        weatherManager.fetchWeather(latitude: 46.7667, longitude: 23.6)
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.tempString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            UserDefaults.standard.setValue(weather.tempString, forKey: "tempLabel")
            UserDefaults.standard.setValue(weather.conditionName, forKey: "conditionImage")
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}


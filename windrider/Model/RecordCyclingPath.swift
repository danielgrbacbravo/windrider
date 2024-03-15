import Foundation
import CoreLocation

class CyclingPathRecorder: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var currentPath: [CLLocationCoordinate2D]
    
    override init() {
        currentPath = [] // Initialize currentPath
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // Request permission when app initializes
    }
    
    func startRecordingPath(name: String) -> CLAuthorizationStatus{
        // Start updating location
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        return locationManager.authorizationStatus
    }
    
    func stopRecordingPath() -> CyclingPath? {
        // Stop updating location
        locationManager.stopUpdatingLocation()
        
        // Create a new CyclingPath object
        if currentPath.count == 0 {
            return nil
        }
        
        let path = CyclingPath(name: "test", coordinates: currentPath)
        return path
    }
    
    func getCurrentPath() -> [CLLocationCoordinate2D]? {
        return currentPath
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Add new coordinates to the current path
        if let location = locations.last {
            currentPath.append(location.coordinate)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // Request authorization here if it's not determined
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        case .restricted, .denied:
            // Handle when the user restricts or denies location services
            break
        case .authorizedWhenInUse, .authorizedAlways:
            // Start updating location if user has granted permission
            manager.startUpdatingLocation()
        @unknown default:
            // Handle future cases
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors
        print("Error: \(error)")
    }
}

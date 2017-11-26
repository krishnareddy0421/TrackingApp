//
//  ViewController.swift
//  TrackingApp
//
//  Created by vamsi krishna reddy kamjula on 11/25/17.
//  Copyright © 2017 kvkr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    
        setUpData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if CLLocationManager.authorizationStatus() == .denied {
            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setUpData() {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            let title = "My Sweet Home"
            let coordinate = CLLocationCoordinate2DMake(38.998696443393825, -76.868639663945075)
            let regionRadius = 100.0
            
            let region = CLCircularRegion(center: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude), radius: regionRadius, identifier: title)
            locationManager.startMonitoring(for: region)
            
            let homeAnnotation = MKPointAnnotation()
            homeAnnotation.coordinate = coordinate
            homeAnnotation.title = "\(title)"
            mapView.addAnnotation(homeAnnotation)
            
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.addOverlays([circle])
        } else {
            print("System can't track regions")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    var monitoredRegions: Dictionary<String, NSDate> = [:]
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        showAlert("Enter \(region.identifier)")
        monitoredRegions[region.identifier] = NSDate()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlert("Exit \(region.identifier)")
        monitoredRegions.removeValue(forKey: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateRegions()
    }
    
    func updateRegions() {
        let regionMaxVisiting = 10.0
        var regionsTodelete: [String] = []
        
        for regionIdentifier in monitoredRegions.keys {
            if NSDate().timeIntervalSince(monitoredRegions[regionIdentifier]! as Date) > regionMaxVisiting {
                showAlert("You left you Home")
                regionsTodelete.append(regionIdentifier)
            }
        }
        
        for regionIdentifier in regionsTodelete {
            monitoredRegions.removeValue(forKey: regionIdentifier)
        }
    }
    
    func showAlert(_ title: String) {
        let alert = UIAlertController.init(title: title, message: "TrackingApp", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


//
//  MapVC.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 15.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import UIKit
import MapKit

protocol MapVCDelegate {
    func getAddress(_ address: String?)
}

class MapVC: UIViewController {
    
    var mapVCDelegate: MapVCDelegate?
    var place = Place()
    let locationManager = CLLocationManager()
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueId = ""
    var directionsArray: [MKDirections]?
    var placeCoordinate: CLLocationCoordinate2D?
    let distance = 1000.0
    var previousLocation: CLLocation? {
        didSet {
            startTrackingLocation()
        }
    }
    
    @IBOutlet weak var getRoute: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        currentAddressLabel.text = " "
        mapView.delegate = self
        super.viewDidLoad()
        setupMapView()
        checkLocationServices()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func findMeButton(_ sender: UIButton) {
        showUserLocation()
    }
    
    
    @IBAction func getRoutePressed(_ sender: UIButton) {
        getDirection()
    }
    @IBAction func doneButtonPressed() {
        mapVCDelegate?.getAddress(currentAddressLabel.text)
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse :
            mapView.showsUserLocation = true
            if incomeSegueId == "chooseAdress" {
                showUserLocation()
            }
            break
        case .authorizedAlways :
            break
        case .denied :
            showAlert(title: "You denied access to the location", message: "Please change it in the settings")
            break
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted :
            showAlert(title: "You denied access to the location", message: "Please change it in the settings")
            break
        @unknown default:
            print("new case is available")
        }
    }
    
    private func showUserLocation() {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: location, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: true)
    }
    
    private func startTrackingLocation() {
        guard let previousLocation = previousLocation else { return }
        let center = getLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    private func setupMapView() {
        getRoute.isHidden = true
        
        if incomeSegueId == "showMap" {
            setupPlacemark()
            mapPinImage.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            getRoute.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections ) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray?.append(directions)
        let _ = directionsArray?.map { $0.cancel() }
        directionsArray?.removeAll()
    }
    
    
    private func getLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func getDirection() {
        guard let location = locationManager.location?.coordinate
            else { showAlert(title: "Error", message: "Current location is not found")
                return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude )
        
        guard let request = createDirectionsRequest(from: location)
            else { showAlert(title: "Error", message: "Destination is not found")
                return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        directions.calculate { ( response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response
                else {
                    self.showAlert(title: "Error", message: "Direction is not available")
                    return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                break;
                
//                let distance = String(format: "%.1f", route.distance / 1000)
//                let timeInterval = route.expectedTravelTime
            }
        }
        
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
}


extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        guard let imageData = place.imageData else { return nil }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(data: imageData)
        
        annotationView?.rightCalloutAccessoryView = imageView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let location = getLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueId == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNum = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNum != nil {
                    self.currentAddressLabel.text = "\(streetName!), \(buildNum!)"
                } else if streetName != nil {
                    self.currentAddressLabel.text = "\(streetName!)"
                } else {
                    self.currentAddressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer  = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

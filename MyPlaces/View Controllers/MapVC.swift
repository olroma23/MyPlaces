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
    
    let mapManager = MapManager()
    var mapVCDelegate: MapVCDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueId = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
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
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func findMeButton(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    
    @IBAction func getRoutePressed(_ sender: UIButton) {
        mapManager.getDirection(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    @IBAction func doneButtonPressed() {
        mapVCDelegate?.getAddress(currentAddressLabel.text)
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
    private func setupMapView() {
        getRoute.isHidden = true
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueId) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueId == "showMap" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            getRoute.isHidden = false
        }
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
        
        let location = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueId == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
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
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueId)
    }
}

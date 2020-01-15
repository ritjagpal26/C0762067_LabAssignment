//
//  ViewController.swift
//  C0762067_LabAssignment
//
//  Created by Mac on 2020-01-14.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import  MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var annotationCordinateArray = [CLLocationCoordinate2D]()
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userlat : Double!
    var destination : CLLocationCoordinate2D!
    var userlong : Double!
    var lat : Double!
    var long : Double!
    var type: String = "car"
    
  
    //Stepper For Zoom In An Zoom OUt
      @IBOutlet weak var stepperoutlet: UIStepper!
    @IBAction func stepperZoom(_ sender: UIStepper) {
        
        if sender.value < 0
               {
                   let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*2, longitudeDelta: mapView.region.span.longitudeDelta*2)
                      let region = MKCoordinateRegion(center: mapView.region.center, span: span)
                       
                      mapView.setRegion(region, animated: true)
               }
               else
               {
                     let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/2, longitudeDelta: mapView.region.span.longitudeDelta/2)
                     let region = MKCoordinateRegion(center: mapView.region.center, span: span)
                      
                     mapView.setRegion(region, animated: true)
               }
        
        
        
    }
    
    //Button to find way for car
    @IBAction func carButton(_ sender: Any) {
       if mapView.overlays.count != 0
       {
           mapView.removeOverlays(mapView.overlays)
       }
       
       let userloaction = mapView.userLocation
            let userlocationcoordinates = CLLocationCoordinate2D(latitude: userloaction.coordinate.latitude, longitude: userloaction.coordinate.longitude)
            let destinationlocation = mapView.annotations
            let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
        routeGuidance(user: userlocationcoordinates, destination1: destinationlocationcoordinates, transportType: .automobile)
        
    }
     //Button to find way for walk
    @IBAction func walkButtton(_ sender: Any) {
       if mapView.overlays.count != 0
       {
           mapView.removeOverlays(mapView.overlays)
       }
       
        let userloaction = mapView.userLocation
            let userlocationcoordinates = CLLocationCoordinate2D(latitude: userloaction.coordinate.latitude, longitude: userloaction.coordinate.longitude)
            let destinationlocation = mapView.annotations
            let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
        routeGuidance(user: userlocationcoordinates, destination1: destinationlocationcoordinates, transportType: .walking)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //location manager
               locationManager.delegate = self
               locationManager.desiredAccuracy = kCLLocationAccuracyBest
               locationManager.requestWhenInUseAuthorization()
               locationManager.startUpdatingLocation()
        // getting location on long =Press
        let onpress = UITapGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(onpress)
        
        stepperoutlet.value = 0
        stepperoutlet.minimumValue = -5
        stepperoutlet.maximumValue = 5
        
  
    }
    
    @objc func longPress(gestureRecognizer: UITapGestureRecognizer) {
        if mapView.annotations.count != 0
        {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "Selected Loaction"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        // To remove the perivious Overlay
        if mapView.overlays.count != 0
        {
            mapView.removeOverlays(mapView.overlays)
        }
        
          destination = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//
//
//
//        annotationCordinateArray.append(cllocation2d)
//
//        print(String(mapView.userLocation.coordinate.latitude) + " Longitude " + String(mapView.userLocation.coordinate.longitude))
//        print(String(annotationCordinateArray[0].latitude) + " Longitude " + String(annotationCordinateArray[0].longitude))
//
//
//
        
        
        
       
    }
   // function of location manager to provide current location of user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
 
    let userLocation: CLLocation = location[0]
    
    let latitude = userLocation.coordinate.latitude
    let longitude = userLocation.coordinate.longitude
        
        userlat = latitude
        userlong = longitude
    
    let latDelta: CLLocationDegrees = 0.05
    let longDelta: CLLocationDegrees = 0.05
    
    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    let region = MKCoordinateRegion(center: location, span: span)
    mapView.setRegion(region, animated: true)
    mapView.showsUserLocation = true
    let annotation = MKPointAnnotation()
    annotation.title = "Present LOaction"
    annotation.coordinate = userLocation.coordinate
    mapView.addAnnotation(annotation)
                   

}

    // location button 
   
    @IBAction func locationButton(_ sender: Any) {
        
        let userloaction = mapView.userLocation
        let userlocationcoordinates = CLLocationCoordinate2D(latitude: userloaction.coordinate.latitude, longitude: userloaction.coordinate.longitude)
        let destinationlocation = mapView.annotations
        let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
        routeGuidance(user: userlocationcoordinates, destination1: destinationlocationcoordinates, transportType: .transit)

        }
    func addPolyLine() {
        var locations = self.annotationCordinateArray
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        mapView.addOverlay(polyline)
    }
    func routeGuidance(user: CLLocationCoordinate2D, destination1: CLLocationCoordinate2D,transportType : MKDirectionsTransportType)
    {
        let direction = MKDirections.Request()
        direction.source = MKMapItem(placemark: MKPlacemark(coordinate: user, addressDictionary: nil))
        direction.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        direction.requestsAlternateRoutes = true
        direction.transportType = transportType

        let directions = MKDirections(request: direction)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            let route = unwrappedResponse.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.delegate = self
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
    }
}
}
// extension of mapview
extension ViewController: MKMapViewDelegate {
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    renderer.strokeColor = UIColor.blue
    return renderer
}
}


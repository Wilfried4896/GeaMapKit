//
//  ViewController.swift
//  GeaMapKit
//
//  Created by Вилфриэд Оди on 13.01.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    var locationUser: CLLocation!
    
    lazy var mapKitView: MKMapView = {
        let mapKitView = MKMapView()
        mapKitView.delegate = self
        mapKitView.translatesAutoresizingMaskIntoConstraints = false
        return mapKitView
    }()
    
    lazy var searchView: UISearchBar = {
        let searchView = UISearchBar()
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.searchTextField.backgroundColor = .clear
        searchView.placeholder = "Введите ваш адрес"
        searchView.delegate = self
        return searchView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configurationView()
    }

    private func configurationView() {
        view.addSubview(mapKitView)
        view.addSubview(searchView)
        
        LocationManager.shared.getUserLocation {[weak self] location in
            guard let self else {
                print("error location")
                return }
            DispatchQueue.main.async {
            self.locationUser = location
            //print(location)
            let pin = Artwork(coordinate: location.coordinate, title: "Моя позиция", subtitle: nil)
            self.mapKitView.centerToLocation(location)
            self.mapKitView.addAnnotation(pin)
        }
    }
        
        NSLayoutConstraint.activate([
            mapKitView.topAnchor.constraint(equalTo: view.topAnchor),
            mapKitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapKitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapKitView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
    }
    
    private func ShowAlert(_ title: String, _ message: String) {
        let messageError = UIAlertController(title: title, message: message, preferredStyle: .alert)
        messageError.addAction(UIAlertAction(title: "OK", style: .destructive))
        present(messageError, animated: true)
    }
    
}

private extension MKMapView {
    func centerToLocation(
        _ locadtion: CLLocation,
        regionRaduis: CLLocationDistance = 800
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: locadtion.coordinate,
            latitudinalMeters: regionRaduis,
            longitudinalMeters: regionRaduis)
        setRegion(coordinateRegion, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let adressSearch = searchBar.text else { return }
        LocationManager.shared.getCoordinate(addressString: adressSearch) { locationSearch in
            switch locationSearch {
            case .success(let coordinatorFound):
                let pin = Artwork(coordinate: coordinatorFound.coordinate, title: adressSearch, subtitle: nil)
                self.mapKitView.centerToLocation(coordinatorFound)
                self.mapKitView.addAnnotation(pin)
            case .failure(let error):
                self.ShowAlert("Внимание", error.localizedDescription)
            }
            self.searchView.endEditing(true)

        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Artwork else { return nil }
        
        let identifier = "artwork"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y:  5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        self.mapKitView.removeOverlays(mapView.overlays)
        
        let view = view.annotation as! Artwork
        let startDestination = MKPlacemark(coordinate: self.locationUser.coordinate)
        let endDestination = MKPlacemark(coordinate: view.coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startDestination)
        request.destination = MKMapItem(placemark: endDestination)
        
        request.transportType = .automobile
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            guard let response else { return }
            for route in response.routes {
                self.mapKitView.addOverlay(route.polyline)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .systemBlue
        return render
    }
}



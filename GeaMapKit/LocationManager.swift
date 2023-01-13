//
//  LocationManager.swift
//  GeaMapKit
//
//  Created by Вилфриэд Оди on 13.01.2023.
//

import Foundation
import CoreLocation
import MapKit

enum GeoMapKitError: Error {
    case DontFoundLocationUser
    case DontFoundLocationAdress
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    var completionHandler: ((CLLocation) -> Void)?
    
    func getUserLocation(completionHandler: @escaping ((CLLocation) -> Void)) {
        self.completionHandler = completionHandler
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
//
//    func getAdress(coord: CLLocation, completionHandler: @escaping (String?, String?) -> Void) {
//        let geocoder = CLGeocoder()
//
//        geocoder.reverseGeocodeLocation(coord) { placemark, error in
//            guard let place = placemark?.first, error == nil else {
//                completionHandler(nil, nil)
//                return
//            }
//
//            var name = ""
//            var subName = ""
//            if let thoroughfare = place.thoroughfare {
//                name += "\(thoroughfare) "
//            }
//            if let subThoroughfare = place.subThoroughfare {
//                name += "\(subThoroughfare), "
//            }
//            if let location = place.locality {
//                name += "\(location) "
//            }
//            if let postalCode = place.postalCode {
//                subName += "\(postalCode), "
//            }
//            if let country = place.country {
//                subName += "\(country)"
//            }
//            completionHandler(name, subName)
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        completionHandler?(location)
        locationManager.stopUpdatingLocation()
    }
    
    func getCoordinate(addressString : String, completionHandler: @escaping ((Result<CLLocation, GeoMapKitError>) -> Void)) {
        
        //self.completionHandler = completionHandler
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            guard let placemarks, let location = placemarks.first?.location else {
                completionHandler(.failure(.DontFoundLocationAdress))
                return
            }
            completionHandler(.success(location))
        }
    }
}

final class Artwork: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}



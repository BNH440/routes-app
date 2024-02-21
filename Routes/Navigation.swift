//
//  Navigation.swift
//  Routes
//
//  Created by Blake Haug on 2/20/24.
//

import Foundation
import SwiftUI
import MapKit

func openAppleMaps(origin: Address, destination: Address, locations: [Address]) {
    let placemarks = [origin] + locations + [destination]
    let mapItems = placemarks.map { placemark in
        let item = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location))
        item.name = placemark.title
        return item
    }
    
    DispatchQueue.main.async {
        MKMapItem.openMaps(
            with: mapItems,
            launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        )
    }
}

func openGoogleMaps(origin: Address, destination: Address, locations: [Address]) {
    let url =  URL(string: "comgooglemapsurl://www.google.com/maps/dir/?api=1&origin=\(origin.addressText)&destination=\(destination.addressText)&waypoints=\(locations.map { "\($0.addressText)" }.joined(separator: "|"))")!
    DispatchQueue.main.async {
        UIApplication.shared.open(url)
    }
}

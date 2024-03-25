//
//  Address.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import Foundation
import MapKit
import SwiftData


struct Coordinate2D: Codable {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Coordinate2D {
    init(_ location: CLLocationCoordinate2D) {
        self.latitude = location.latitude
        self.longitude = location.longitude
    }

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

@Model
class Address: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let location: Coordinate2D
    let addressText: String
    
    static func == (lhs: Address, rhs: Address) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(title: String, location: CLLocationCoordinate2D, addressText: String) {
        self.title = title
        self.location = Coordinate2D(location)
        self.addressText = addressText
    }
}

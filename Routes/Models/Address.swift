//
//  Address.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import Foundation
import MapKit


struct Address: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let location: CLLocationCoordinate2D
    let addressText: String
    
    static func == (lhs: Address, rhs: Address) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

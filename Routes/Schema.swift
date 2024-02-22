//
//  Schema.swift
//  Routes
//
//  Created by Blake Haug on 1/2/24.
//

import Foundation
import MapKit


// MARK: - Response
struct Response: Codable {
    let routes: [SchemaRoute]
}

struct SchemaRoute: Codable {
    let optimizedIntermediateWaypointIndex: [Int]
}

// MARK: - Request
struct RouteRequest: Codable {
    let origin, destination: RequestAddress
    let intermediates: [RequestAddress]
    let travelMode: TravelMode
    let optimizeWaypointOrder: StringBool
}

struct RequestAddress: Codable {
    let location: Location
}

struct Location: Codable {
    let latLng: LatLng
}

struct LatLng: Codable {
    let latitude, longitude: Double
}

enum TravelMode: String, Codable {
    case drive = "DRIVE"
    case bicycle = "BICYCLE"
    case walk = "WALK"
}

enum StringBool: String, Codable {
    case t = "true"
    case f = "false"
}


func addressToRequestAddress(address: Address) -> RequestAddress {
    return RequestAddress(location: Location(latLng: LatLng(latitude: address.location.latitude, longitude: address.location.longitude)))
}

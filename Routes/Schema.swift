//
//  Schema.swift
//  Routes
//
//  Created by Blake Haug on 1/2/24.
//

import Foundation


// MARK: - Response
struct Response: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let optimizedIntermediateWaypointIndex: [Int]
}

// MARK: - Request
struct RouteRequest: Codable {
    let origin, destination: Address
    let intermediates: [Address]
    let travelMode: TravelMode
    let optimizeWaypointOrder: StringBool
}

struct Address: Codable {
    let address: String
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


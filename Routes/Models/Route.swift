//
//  Route.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import Foundation
import MapKit
import SwiftData

@Model
class Route: Equatable, Hashable {
    var id: UUID
    var title: String
    var locations: [Address]
    var origin: Address
    var destination: Address
    var idealRoute: [Int]
    var idealRouteGenerationDate: Date
    var creationDate: Date
    var snapshot: Data?
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: UUID, title: String, locations: [Address], origin: Address, destination: Address, idealRoute: [Int], idealRouteGenerationDate: Date, creationDate: Date = .now, snapshot: Data? = nil) {
        self.id = id
        self.title = title
        self.locations = locations
        self.origin = origin
        self.destination = destination
        self.idealRoute = idealRoute
        self.idealRouteGenerationDate = idealRouteGenerationDate
        self.creationDate = creationDate
        self.snapshot = snapshot;
    }
}


let exampleRouteArray: [Route] = [
    Route(id: UUID.init(), title: "Route 1", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now),
    Route(id: UUID.init(), title: "Route 2", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now),
    Route(id: UUID.init(), title: "Route 3", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now)
] // DEBUG

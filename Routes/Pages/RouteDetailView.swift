//
//  RouteDetailView.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import SwiftUI
import MapKit
import SwiftData
import Foundation

struct RouteDetailView: View {
    var routeID: UUID
    @Query var routes: [Route]
    var route: Route {
        routes.first(where: { $0.id == routeID })!
    }
    
    var body: some View {
        VStack {

        }.navigationTitle(route.title)
    }
}

//#Preview {
//    RouteDetailView(route: Route(id: UUID.init(), title: "Route 1", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now))
//}

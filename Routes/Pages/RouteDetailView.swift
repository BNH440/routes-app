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
    var routeID: PersistentIdentifier
    @Query var routes: [Route]
    @Environment(\.modelContext) var modelContext

    
    var body: some View {
        var route: Route = modelContext.model(for: routeID) as! Route
        var computedRoute = route.idealRoute.map { route.locations[$0] };
        
        VStack {
            // show new map view with waypoints
            Button("Open in Apple Maps") {
                openAppleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)

            }
            Button("Open in Google Maps") {
                openGoogleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)
            }
            

            List {
                Section(header: Text("Route Details")) {
                    HStack {
                        Text("Title")
                        Spacer()
                        Text(route.title)
                    }
                    HStack {
                        Text("Origin")
                        Spacer()
                        Text(route.origin.title)
                    }
                    HStack {
                        Text("Destination")
                        Spacer()
                        Text(route.destination.title)
                    }
                    HStack {
                        Text("Ideal Route Generation Date")
                        Spacer()
                        Text(route.idealRouteGenerationDate, style: .date)
                    }
                }
                Section(header: Text("Locations")) {
                    ForEach(computedRoute) { location in
                        HStack {
                            Text(location.title)
                            Spacer()
                            Text(location.addressText)
                        }
                    }
                }
            }
            
            StaticMapView(coordinates: [route.origin.location.location] + addressArrayToCLLocation2DArray(addresses: computedRoute) + [route.destination.location.location])
                .edgesIgnoringSafeArea(.all)
        }.navigationTitle(route.title)
    }
}

//#Preview {
//    RouteDetailView(route: Route(id: UUID.init(), title: "Route 1", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now))
//}

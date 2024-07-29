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
            List {
                Section(header: Text("Route Details")) {
                    HStack {
                        Text("Generation Date")
                        Spacer()
                        Text(route.idealRouteGenerationDate, style: .date)
                    }
                    
                    // show new map view with waypoints
                    Button("Open in Apple Maps") {
                        openAppleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)

                    }
                    Button("Open in Google Maps") {
                        openGoogleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)
                    }
                }
                
                StaticMapView(coordinates: [route.origin.location.location] + addressArrayToCLLocation2DArray(addresses: computedRoute) + [route.destination.location.location])
                    .frame(height: 450)
//                    .edgesIgnoringSafeArea(.all)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                
                Section(header: Text("Locations")) {
                    HStack {
                        Text("Origin")
                        Spacer()
                        Text(route.origin.title)
                    }
                    ForEach(computedRoute) { location in
                        HStack {
                            Text("Waypoint \((computedRoute.firstIndex(of: location) ?? 0)+1)")
                            Spacer()
                            Text(location.title)
                        }
                    }
                    HStack {
                        Text("Destination")
                        Spacer()
                        Text(route.destination.title)
                    }
                }
            }
        }.navigationTitle(route.title).enableInjection()
    }
}

//#Preview {
//    RouteDetailView(route: Route(id: UUID.init(), title: "Route 1", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now))
//}

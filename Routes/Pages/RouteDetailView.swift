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
        var waypoints: [MKMapItem] {
            var items = [MKMapItem]()
            items.append(MKMapItem(placemark: MKPlacemark(coordinate: route.origin.location.location)))
            for point in route.idealRoute {
                let location = route.locations[point]
                let placemark = MKPlacemark(coordinate: location.location.location)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = location.title
                items.append(mapItem)
            }
            items.append(MKMapItem(placemark: MKPlacemark(coordinate: route.destination.location.location)))
            return items
        }
        
        VStack {
            // show new map view with waypoints
            Button("Open in Apple Maps") {
                openAppleMaps(origin: route.origin, destination: route.destination, locations: route.idealRoute.map { route.locations[$0] })

            }
            Button("Open in Google Maps") {
                openGoogleMaps(origin: route.origin, destination: route.destination, locations: route.idealRoute.map { route.locations[$0] })
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
                    ForEach(route.locations) { location in
                        HStack {
                            Text(location.title)
                            Spacer()
                            Text(location.addressText)
                        }
                    }
                }
            }
        }.navigationTitle(route.title)
    }
}

//#Preview {
//    RouteDetailView(route: Route(id: UUID.init(), title: "Route 1", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now))
//}

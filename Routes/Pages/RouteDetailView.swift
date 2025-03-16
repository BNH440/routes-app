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
    @State private var showingActionSheet = false
    
    enum MapApp: String {
        case appleMaps
        case googleMaps
    }
    
    func setDefaultMapApp(mapApp: MapApp) {
        UserDefaults.standard.set(mapApp.rawValue, forKey: "defaultMapApp")
    }

    func getDefaultMapApp() -> MapApp? {
        if let storedValue = UserDefaults.standard.string(forKey: "defaultMapApp") {
            return MapApp(rawValue: storedValue)  // Ensure it's properly cast to MapType
        }
        return nil
    }

    var body: some View {
        let route: Route = modelContext.model(for: routeID) as! Route
        let computedRoute = route.idealRoute.map { route.locations[$0] };
        
        VStack {
            List {
                Section() {
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

                    Button("Open in Maps") {
                        // TODO: check that google maps is actually installed before showing sheet
                        if (getDefaultMapApp() == nil) {
                            showingActionSheet.toggle()
                        }
                        else{
                            let chosenApp = getDefaultMapApp()!
                            switch chosenApp {
                            case .appleMaps:
                                openAppleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)
                            case .googleMaps:
                                openGoogleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)
                            }
                        }
                    }.actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(
                            title: Text("Choose Default App"),
                            buttons: [
                                .default(Text("Apple Maps")) {
                                    setDefaultMapApp(mapApp: .appleMaps)
                                    openAppleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)
                                },
                                .default(Text("Google Maps")) {
                                    setDefaultMapApp(mapApp: .googleMaps)
                                    openGoogleMaps(origin: route.origin, destination: route.destination, locations: computedRoute)
                                },
                                .cancel()
                            ]
                        )
                    }
                    
                    HStack(spacing: 0) {  // Adjust the spacing between items
                        Text("Last Updated:").padding(.trailing, 6)
                        Text(route.idealRouteGenerationDate, style: .date)
                        Text("at").padding(.horizontal, 4)
                        Text(route.idealRouteGenerationDate, style: .time)
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                StaticMapView(coordinates: [route.origin.location.location] + addressArrayToCLLocation2DArray(addresses: computedRoute) + [route.destination.location.location])
                    .frame(height: 450)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
        }.navigationTitle(route.title).enableInjection()
    }
}

//#Preview {
//    RouteDetailView(route: Route(id: UUID.init(), title: "Route 1", locations: [Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"),Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln")], origin: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), destination: Address(title: "Example House", location: CLLocationCoordinate2D(latitude: 1, longitude: 1), addressText: "6621 Elmore ln"), idealRoute: [1,0], idealRouteGenerationDate: Date.now))
//}

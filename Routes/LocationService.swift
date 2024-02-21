//
//  LocationService.swift
//  Routes
//
//  Created by Blake Haug on 2/19/24.
//
//  Credit to https://www.polpiella.dev/mapkit-and-swiftui-searchable-map
//  for example code to create the address search feature
//
//  And https://gist.github.com/SergLam/44305a41ff143d47688710121d8991a7
//  for the address name conversion
//

import Foundation
import MapKit
import CoreLocation


struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let location: CLLocationCoordinate2D
    let address: String

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


@Observable
class LocationService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter

    var completions = [SearchCompletions]()

    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }

    func update(queryFragment: String) {
        completer.resultTypes = [.address, .pointOfInterest]
        completer.queryFragment = queryFragment
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            completions = completer.results.map { completion in
                // Get the private _mapItem property
//                let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem

                return .init(
                    title: completion.title,
                    subTitle: completion.subtitle
                )
            }
        }
    
    func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResult] {
            let mapKitRequest = MKLocalSearch.Request()
            mapKitRequest.naturalLanguageQuery = query
            mapKitRequest.resultTypes = [.address, .pointOfInterest]
            if let coordinate {
                mapKitRequest.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
            }
            let search = MKLocalSearch(request: mapKitRequest)

            let response = try await search.start()

            return response.mapItems.compactMap { mapItem in
                guard let location = mapItem.placemark.location?.coordinate else { return nil }
                let address = "\(mapItem.placemark.subThoroughfare ?? "") \(mapItem.placemark.thoroughfare ?? ""), \(mapItem.placemark.locality ?? "") \(mapItem.placemark.administrativeArea ?? "") \(mapItem.placemark.postalCode ?? "")"

                return .init(location: location, address: address)
            }
        }
}

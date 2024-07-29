//
//  MapView.swift
//  Routes
//
//  Created by Blake Haug on 7/28/24.
//

import Foundation
import SwiftUI
import MapKit

struct StaticMapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: StaticMapView
        
        init(parent: StaticMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = false
        
//        // Center the map on the first coordinate
//        if let firstCoordinate = coordinates.first {
//            let region = MKCoordinateRegion(center: firstCoordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
//            mapView.setRegion(region, animated: true)
//        }
        
        // Center the map on the entire route
        let region = calculateRegion(for: coordinates)
        mapView.setRegion(region, animated: true)
        
        addRoute(to: mapView)
        addAnnotations(to: mapView)
        
        return mapView
    }
    
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates.first?.latitude ?? 0.0
        var maxLat = coordinates.first?.latitude ?? 0.0
        var minLon = coordinates.first?.longitude ?? 0.0
        var maxLon = coordinates.first?.longitude ?? 0.0
        
        for coordinate in coordinates {
            if coordinate.latitude < minLat {
                minLat = coordinate.latitude
            }
            if coordinate.latitude > maxLat {
                maxLat = coordinate.latitude
            }
            if coordinate.longitude < minLon {
                minLon = coordinate.longitude
            }
            if coordinate.longitude > maxLon {
                maxLon = coordinate.longitude
            }
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5, longitudeDelta: (maxLon - minLon) * 1.5) // 1.2
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // No need to update the view
    }
    
    private func addRoute(to mapView: MKMapView) {
        let request = MKDirections.Request()
        let waypoints: [MKPlacemark] = coordinates.map { MKPlacemark(coordinate: $0) }
        
        for i in 0..<(waypoints.count - 1) {
            let source = waypoints[i]
            let destination = waypoints[i + 1]
            
            request.source = MKMapItem(placemark: source)
            request.destination = MKMapItem(placemark: destination)
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let route = response?.routes.first else { return }
                mapView.addOverlay(route.polyline)
            }
        }
    }
    
    private func addAnnotations(to mapView: MKMapView) {
            for (index, coordinate) in coordinates.enumerated() {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                if index == 0 {
                    annotation.title = "Start"
                } else if index == coordinates.count - 1 {
                    annotation.title = "End"
                } else {
                    annotation.title = "Waypoint \(index)"
                }
                mapView.addAnnotation(annotation)
            }
        }
}

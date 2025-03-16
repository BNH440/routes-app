//
//  SnapshotMap.swift
//  Routes
//
//  Created by Blake Haug on 3/15/25.
//

import Foundation
import MapKit
import SwiftData

func snapshotMap(from mapView: MKMapView, completion: @escaping (UIImage?) -> Void) {
    let options = MKMapSnapshotter.Options()
    options.region = mapView.region;
    options.size = CGSize(width: 65, height: 65);
    options.preferredConfiguration = MKStandardMapConfiguration(emphasisStyle: .muted);
    
    let snapshotter = MKMapSnapshotter(options: options)
    snapshotter.start { snapshot, error in
        guard let snapshot = snapshot, error == nil else {
            print("Snapshot error:", error?.localizedDescription ?? "Unknown error")
            completion(nil)
            return
        }

        // Draw polylines on the snapshot
        let finalImage = drawPolylines(on: snapshot, from: mapView)
        completion(finalImage)
    }
}

func drawPolylines(on snapshot: MKMapSnapshotter.Snapshot, from mapView: MKMapView) -> UIImage {
    let image = snapshot.image
    let renderer = UIGraphicsImageRenderer(size: image.size)

    return renderer.image { context in
        image.draw(at: .zero)

        let context = context.cgContext
        context.setLineWidth(2.5)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineJoin(.round)
        context.setLineCap(.round)

        for overlay in mapView.overlays {
            if let polyline = overlay as? MKPolyline {
                drawPolyline(polyline, on: snapshot, using: context)
            }
        }
    }
}

func drawPolyline(_ polyline: MKPolyline, on snapshot: MKMapSnapshotter.Snapshot, using context: CGContext) {
    let path = UIBezierPath()
    var isFirstPoint = true

    for i in 0..<polyline.pointCount {
        let mapPoint = polyline.points()[i]
        let coordinate = mapPoint.coordinate  // Corrected line
        let point = snapshot.point(for: coordinate)

        if isFirstPoint {
            path.move(to: point)
            isFirstPoint = false
        } else {
            path.addLine(to: point)
        }
    }

    path.lineWidth = 2.5
    UIColor.systemBlue.setStroke()
    path.stroke()
}

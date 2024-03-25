//
//  RoutesApp.swift
//  Routes
//
//  Created by Blake Haug on 1/2/24.
//

import SwiftUI
import SwiftData
@_exported import Inject

@main
struct RoutesApp: App {
    @ObserveInjection var inject
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: Route.self)
    }
}

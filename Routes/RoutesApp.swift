//
//  RoutesApp.swift
//  Routes
//
//  Created by Blake Haug on 1/2/24.
//

import SwiftUI
@_exported import Inject

@main
struct RoutesApp: App {
    @ObserveInjection var inject
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

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
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue

    var body: some Scene {
        WindowGroup {
            MainView().preferredColorScheme(colorScheme(for: selectedTheme))
        }
        .modelContainer(for: Route.self)
    }
    
    private func colorScheme(for theme: String) -> ColorScheme? {
        switch theme {
        case Theme.light.rawValue:
            return .light
        case Theme.dark.rawValue:
            return .dark
        default:
            return nil // System
        }
    }
}

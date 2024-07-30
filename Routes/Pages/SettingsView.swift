//
//  SettingsView.swift
//  Routes
//
//  Created by Blake Haug on 7/29/24.
//

import Foundation
import SwiftUI

enum Theme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

enum NavigationMode: String, CaseIterable {
    case driving = "Driving"
    case walking = "Walking"
    case bicycling = "Biking"
}

struct SettingsView: View {
    @ObserveInjection var inject

    @Binding var isPresented: Bool
    
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("selectedMode") private var selectedMode: String = NavigationMode.driving.rawValue
    
    private var theme: Theme {
        Theme(rawValue: selectedTheme) ?? .system
    }
    
    var body: some View {
        NavigationView {
            Form {
//                Section(header: Text("Default Route Options")) {
//                    Picker("Navigation Mode (WIP)", selection: $selectedMode) {
//                        ForEach(NavigationMode.allCases, id: \.self) { theme in
//                            Text(theme.rawValue).tag(theme.rawValue)
//                        }
//                    }
//                }
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }.enableInjection()
    }
}

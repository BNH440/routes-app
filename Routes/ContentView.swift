//
//  ContentView.swift
//  Routes
//
//  Created by Blake Haug on 1/2/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @ObserveInjection var inject
    
    @State private var origin = ""
    @State private var location1 = ""
    @State private var location2 = ""
    @State private var location3 = ""
    @State private var location4 = ""
    @State private var destination = ""
    
    @State private var responseState: Response? = nil;

    
    func calculateRoute (origin: String, location1: String, location2: String, location3: String, location4: String, destination: String) {
        let route = RouteRequest(
            origin: Address(address: origin),
            destination: Address(address: destination),
            intermediates: [
                Address(address: location1),
                Address(address: location2),
                Address(address: location3),
                Address(address: location4)
            ],
            travelMode: TravelMode.drive,
            optimizeWaypointOrder: StringBool.t
        )
        
        let data = try! JSONEncoder().encode(route)
        
        var request = URLRequest(url: URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes")!,timeoutInterval: 10000)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("AIzaSyBTA5p__tNNyJ4BDXQTgnZO1DphV8Grdcg", forHTTPHeaderField: "X-Goog-Api-Key")
        request.addValue("routes.optimizedIntermediateWaypointIndex", forHTTPHeaderField: "X-Goog-FieldMask")
        
        request.httpMethod = "POST"
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            let response = try! JSONDecoder().decode(Response.self, from: data)
            print(response)
//            responseState = response;
            return
        }
        
        task.resume()
    }
    
    
    func routeButton() {
        calculateRoute(origin: origin, location1: location1, location2: location2, location3: location3, location4: location4, destination: destination)
    }
    
    var body: some View {
        @ObserveInjection var inject

        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "map.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Routes")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .padding(.top)
            VStack {
                TextField(text: $origin, prompt: Text("Origin")) {
                    Text("Origin")
                }
                TextField(text: $location1, prompt: Text("Location 1")) {
                    Text("Location 1")
                }
                TextField(text: $location2, prompt: Text("Location 2")) {
                    Text("Location 2")
                }
                TextField(text: $location3, prompt: Text("Location 3")) {
                    Text("Location 3")
                }
                TextField(text: $location4, prompt: Text("Location 4")) {
                    Text("Location 4")
                }
                TextField(text: $destination, prompt: Text("Destination")) {
                    Text("Destination")
                }
                
            }.padding()
            Button(action: routeButton) {
                Text("Calculate Route")
            }
            .padding()
            
            if (responseState != nil){
                VStack(alignment: .leading) {
                    Text("Route")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Origin: \(origin)")
                    Text("Location 1: \(location1)")
                    Text("Location 2: \(location2)")
                    Text("Location 3: \(location3)")
                    Text("Location 4: \(location4)")
                    Text("Destination: \(destination)")
                }
            }
            Spacer()
        }
        .padding()
        .enableInjection()
    }
}

#Preview {
    ContentView()
}

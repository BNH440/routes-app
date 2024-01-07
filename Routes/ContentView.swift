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
    @State private var locations = ["", "", "", ""]
    @State private var destination = ""
    
    @State private var responseState: Response? = nil;
    
    
    func calculateRoute () {
        let route = RouteRequest(
            origin: Address(address: origin),
            destination: Address(address: destination),
            intermediates: [
                Address(address: locations[0]),
                Address(address: locations[1]),
                Address(address: locations[2]),
                Address(address: locations[3])
            ],
            travelMode: TravelMode.drive,
            optimizeWaypointOrder: StringBool.t
        )
        
        let data = try! JSONEncoder().encode(route)
        
        var request = URLRequest(url: URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("", forHTTPHeaderField: "X-Goog-Api-Key")
        request.addValue("routes.optimizedIntermediateWaypointIndex", forHTTPHeaderField: "X-Goog-FieldMask")
        
        request.httpMethod = "POST"
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            let response = try? JSONDecoder().decode(Response.self, from: data)
            if(response == nil) {
                print("Error decoding response")
                return
            }
            print(response!)
            responseState = response;
            return
        }
        
        task.resume()
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
                TextField(text: $locations[0], prompt: Text("Location 1")) {
                    Text("Location 1")
                }
                TextField(text: $locations[1], prompt: Text("Location 2")) {
                    Text("Location 2")
                }
                TextField(text: $locations[2], prompt: Text("Location 3")) {
                    Text("Location 3")
                }
                TextField(text: $locations[3], prompt: Text("Location 4")) {
                    Text("Location 4")
                }
                TextField(text: $destination, prompt: Text("Destination")) {
                    Text("Destination")
                }
                
            }.padding()
            Button(action: calculateRoute) {
                Text("Calculate Route")
            }
            .padding()
            
            if (responseState != nil){
                CapsuleLineSegment(items: ["Origin: \(origin)",
                                           "Location 1: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[0] ?? 0)])",
                                           "Location 2: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[1] ?? 0)])",
                                           "Location 3: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[2] ?? 0)])",
                                           "Location 4: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[3] ?? 0)])",
                                           "Destination: \(destination)"
                                          ])
            }
            
            
            CapsuleLineSegment(items: ["Origin: \(origin)",
                                       "Location 1: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[0] ?? 0)])",
                                       "Location 2: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[1] ?? 0)])",
                                       "Location 3: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[2] ?? 0)])",
                                       "Location 4: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[3] ?? 0)])",
                                       "Destination: \(destination)"
                                      ])
            
            Spacer()
        }
        .padding()
        .enableInjection()
    }
}

#Preview {
    ContentView()
}

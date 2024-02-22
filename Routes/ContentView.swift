//
//  ContentView.swift
//  Routes
//
//  Created by Blake Haug on 1/2/24.
//

import SwiftUI
import Foundation
import MapKit

struct ContentView: View {
    @ObserveInjection var inject
    
    @State private var origin: Address? = nil
    @State private var locations: [Address] = []
    @State private var destination: Address? = nil
    @State private var responseState: Response? = nil;
    
    @State private var showModal = false
    
    enum ChangeVar {
        case origin, destination, point
    }
    
    @State private var changeVar: ChangeVar = .origin
    
    
    func calculateRoute () {
        guard origin != nil else {
            print("Origin is nil")
            return
        }
        
        guard destination != nil else {
            print("Destination is nil")
            return
        }
        
        guard locations.count > 1 else {
            print("Not enough intermediate points")
            return
        }
        
        let route = RouteRequest(
            origin: addressToRequestAddress(address: origin!),
            destination: addressToRequestAddress(address: destination!),
            intermediates: locations.map { addressToRequestAddress(address: $0) },
            travelMode: TravelMode.drive,
            optimizeWaypointOrder: StringBool.t
        )
        
        let data = try! JSONEncoder().encode(route)
        
        var request = URLRequest(url: URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes")!)
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
            let response = try? JSONDecoder().decode(Response.self, from: data)
            if(response == nil) {
                print("Error decoding response")
                return
            }
            print(response!)
            responseState = response;
            
//            openAppleMaps(origin: origin!, destination: destination!, locations: responseState!.routes[0].optimizedIntermediateWaypointIndex.map { locations[$0] })
            openGoogleMaps(origin: origin!, destination: destination!, locations: responseState!.routes[0].optimizedIntermediateWaypointIndex.map { locations[$0] })
            return
        }
        
        task.resume()
    }
    
    struct AddressSheet : View {
        @State private var search = ""
        @State private var searchResults: [SearchResult] = []
        @Binding var showModal: Bool
        @Binding var locations: [Address]
        @Binding var origin: Address?
        @Binding var destination: Address?
        @Binding var changeVar: ChangeVar
        @State private var locationService = LocationService(completer: .init())
        
        @FocusState private var keyboardFocused: Bool
        
        
            var body: some View {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search for an address", text: $search)
                            .autocorrectionDisabled()
                            .focused($keyboardFocused)
                            .onAppear {
                                keyboardFocused = true
                            }
                            .onSubmit {
                                Task {
                                    searchResults = (try? await locationService.search(with: search)) ?? []
                                }
                            }
                    }
                    .padding(12)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    
                    if locationService.completions.isEmpty {
                        Spacer()

                        if search.isEmpty {
                            Text("Start typing to search for an address")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        } else {
                            VStack(spacing: 16) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(.gray)
                                        Text("No results found")
                                            .font(.title)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                        }
                        Spacer()

                    }
                    else{
                        Spacer()

                        List {
                            ForEach(locationService.completions) { completion in
                                Button(action: { didTapOnCompletion(completion) }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(completion.title)
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                        Text(completion.subTitle)
                                    }
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .onChange(of: search) {
                    locationService.update(queryFragment: search)
                }
                .padding()
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
                .presentationBackground(.regularMaterial)
            }

            private func didTapOnCompletion(_ completion: SearchCompletions) {
                Task {
                    if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                        showModal = false
                        searchResults = [singleLocation]
                        
                        let newAddress = Address(title: completion.title, location: singleLocation.location, addressText: singleLocation.address)

                        if(changeVar == .origin){
                            origin = newAddress
                        }
                        else if(changeVar == .destination){
                            destination = newAddress                        }
                        else if(changeVar == .point){
                            locations.append(newAddress)
                        }
                    }
                }
            }
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
            Divider()
                .padding(.bottom)
            VStack(alignment: .leading) {
                
                Text("Points")
                    .font(.title2)
                    .fontWeight(.semibold)
                VStack (alignment: .leading){

                    Button(origin?.title ?? "Select...") {
                        changeVar = .origin
                        showModal = true
                    }
                    .sheet(isPresented: $showModal) {
                        AddressSheet(showModal: $showModal, locations: $locations, origin: $origin, destination: $destination, changeVar: $changeVar)
                    }
                    .buttonStyle(.bordered)
                    
                    ForEach(Array(locations.enumerated()), id: \.1) { index, loc in
                        Text(loc.title)
                    }
                    
                    
                    Button(action: {
                        changeVar = .point
                        showModal = true
                    }){
                        Label("Add Location", systemImage: "plus.square.fill.on.square.fill")
                      }
                    .sheet(isPresented: $showModal) {
                        AddressSheet(showModal: $showModal, locations: $locations, origin: $origin, destination: $destination, changeVar: $changeVar)
                    }
                    .buttonStyle(.bordered)

                    
                    Button(destination?.title ?? "Select...") {
                        changeVar = .destination
                        showModal = true
                    }
                    .sheet(isPresented: $showModal) {
                        AddressSheet(showModal: $showModal, locations: $locations, origin: $origin, destination: $destination, changeVar: $changeVar)
                    }
                    .buttonStyle(.bordered)

                    
                    
                }.padding()
                Button(action: calculateRoute) {
                    Text("Calculate Route")
                }
                .padding()
                .disabled(origin == nil || destination == nil || locations.count < 2)
                
                if(responseState != nil){
                    CapsuleLineSegment(items: ["Origin: \(origin!.title)"] +
                                       (responseState?.routes[0].optimizedIntermediateWaypointIndex.map { locations[$0].title } ?? [""]) +
                                       ["Destination: \(destination!.title)"])
                }
            }.padding(10)
            Spacer()
        }
        .padding()
        .enableInjection()
    }
}

#Preview {
    ContentView()
}

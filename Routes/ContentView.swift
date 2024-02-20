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
    
    @State private var origin = ""
    @State private var locations = [""]
    @State private var destination = ""
    @State private var responseState: Response? = nil;
    
    @State private var showModal = false
    
    enum ChangeVar {
        case origin, destination, point
    }
    
    @State private var changeVar: ChangeVar = .origin
    
    
    func calculateRoute () {
        let route = RouteRequest(
            origin: Address(address: origin),
            destination: Address(address: destination),
            intermediates: locations.map { Address(address: $0) },
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
            return
        }
        
        task.resume()
    }
    
    func search () {
        
    }
    
    // TODO pass in address variabke for this button. Button will pop up modal sheet to search for address and then fill in the address variable
    struct AddressSheet : View {
        @State private var searchText = ""
        @State private var searchResults: [MKMapItem] = []
        @Binding var showModal: Bool
        @Binding var locations: [String]
        @Binding var origin: String
        @Binding var destination: String
        @Binding var changeVar: ChangeVar
        @State private var locationService = LocationService(completer: .init())
        
        func performLocalSearch() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.resultTypes = .address

            let search = MKLocalSearch(request: request)
            search.start { response, error in guard
                let response = response else {
                    // Handle error
                    return
                }

                searchResults = response.mapItems
            }
        }
        
        
        var body: some View {
            VStack {
                // 1
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search for an address", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.primary)
                
                Spacer()
                
                List {
                    ForEach(locationService.completions) { completion in
                        Button(action: {
                            showModal = false
                            searchText = completion.title
    
                            if(changeVar == .origin){
                                origin = searchText
                            }
                            else if(changeVar == .destination){
                                destination = searchText
                            }
                            else if(changeVar == .point){
                                locations.append(searchText)
                            }
    
    
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(completion.title)
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                Text(completion.subTitle)
                            }
                        }
                        // 3
                        .listRowBackground(Color.clear)
                    }
                }
                // 4
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .onChange(of: searchText){
                locationService.update(queryFragment: searchText)
            }
            .padding()
            // 2
//            .interactiveDismissDisabled()
            // 3
            .presentationDetents([.height(600), .large])
            // 4
            .presentationBackground(.regularMaterial)
            // 5
//            .presentationBackgroundInteraction(.enabled(upThrough: .large))
        }
//        
//        var body: some View{
//            VStack {
//                HStack {
//                    TextField("Search...", text: $searchText)
//                        .onChange(of: searchText) {
//                            performLocalSearch()
//                    }
//                    Button("Cancel") {
//                        showModal = false
//                        searchText = ""
//                    }
//                }
//                .padding()
//                
//                List(searchResults, id: \.self) { result in
//                    Button(action: {
//                        showModal = false
//                        searchText = result.name ?? "Unknown"
//                        
//                        if(changeVar == .origin){
//                            origin = searchText
//                        }
//                        else if(changeVar == .destination){
//                            destination = searchText
//                        }
//                        else if(changeVar == .point){
//                            locations.append(searchText)
//                        }
//                        
//                        
//                    }, label: {
//                        Text("\(result.name ?? "Unknown")")
//                    })
//                }
//            }}
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

                    Button(origin) {
                        changeVar = .origin
                        showModal = true
                    }
                    .sheet(isPresented: $showModal) {
                        AddressSheet(showModal: $showModal, locations: $locations, origin: $origin, destination: $destination, changeVar: $changeVar)
                    }
                    .buttonStyle(.bordered)
                    
                    ForEach(Array(locations.enumerated()), id: \.1) { index, string in
                        Text(string)
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

                    
                    Button(destination) {
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
                
                if(responseState != nil){
                    CapsuleLineSegment(items: ["Origin: \(origin)",
                                               "Location 1: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[0] ?? 0)])",
                                               "Location 2: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[1] ?? 0)])",
                                               "Location 3: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[2] ?? 0)])",
                                               "Location 4: \(locations[Int(responseState?.routes[0].optimizedIntermediateWaypointIndex[3] ?? 0)])",
                                               "Destination: \(destination)"
                                              ])
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

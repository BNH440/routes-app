//
//  CreateRouteView.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import SwiftUI

struct CreateRoutePage: View {
    @ObserveInjection var inject
    
    @State private var origin: Address? = nil
    @State private var locations: [Address] = []
    @State private var destination: Address? = nil
    @State private var name: String = ""
    
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
            VStack (alignment: .leading){
                HStack{
                    Text("Name: ").bold()
                    TextField("Enter a name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                
                HStack{
                    Text("Origin: ").bold()
                    Button(origin?.title ?? "Select...") {
                        changeVar = .origin
                        showModal = true
                    }
                    .sheet(isPresented: $showModal) {
                        AddressSheet(showModal: $showModal, locations: $locations, origin: $origin, destination: $destination, changeVar: $changeVar)
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("Intermediate Points: ").bold()
                
                List{
                    ForEach(Array(locations.enumerated()), id: \.1) { index, loc in
                        Text(loc.title).swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                            Button(action: {
                                print("Delete")
                                locations.remove(at: index)
                            }){
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        })
                    }
                }
                .listStyle(.inset)
                
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

                HStack{
                    Text("Destination: ").bold()
                    Button(destination?.title ?? "Select...") {
                        changeVar = .destination
                        showModal = true
                    }
                    .sheet(isPresented: $showModal) {
                        AddressSheet(showModal: $showModal, locations: $locations, origin: $origin, destination: $destination, changeVar: $changeVar)
                    }
                    .buttonStyle(.bordered)
                }
            }
                    
//                    if(responseState != nil){
//                        CapsuleLineSegment(items: ["Origin: \(origin!.title)"] +
//                                           (responseState?.routes[0].optimizedIntermediateWaypointIndex.map { locations[$0].title } ?? [""]) +
//                                           ["Destination: \(destination!.title)"])
//                    }
            Spacer()
            
            Button(action: calculateRoute, label: {
                Text("Create Route")
            })
            .buttonStyle(.bordered)
            .controlSize(.extraLarge)
            .tint(.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .disabled(origin == nil || destination == nil || locations.count < 2 || name == "")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .navigationTitle("Create Route").enableInjection()
    }
}

#Preview {
    CreateRoutePage()
}

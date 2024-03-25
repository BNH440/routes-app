//
//  MainView.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @ObserveInjection var inject
    @Query(sort: \Route.creationDate, order: .reverse) var routes: [Route]
    @Environment(\.modelContext) var modelContext
    
    func addExampleData() {
        if(routes.isEmpty){
            for route in exampleRouteArray {
                modelContext.insert(route);
            }
        }
    }

    var body: some View {
        @ObserveInjection var inject

        NavigationView {
                    List {
                        ForEach(routes, id: \.id) { route in
                            //                    NavigationLink(destination: nil) { // RouteDetailView(route: route)
                            NavigationLink(destination: RouteDetailView(routeID: route.id)){
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading) {
                                        Text(route.title)
                                            .font(.title3)
                                        Text("\(route.origin.title) to \(route.destination.title)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    // placeholder map
                                    Image(systemName: "map")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }.swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                                    Button(action: {
                                        modelContext.delete(route);
                                        print("Delete")
                                    }){
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                })}
                            //                    }
                }
                .padding()
            }
            .listStyle(.inset)
            .navigationTitle("Routes")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("Settings")
                    }){
                        Image(systemName: "gearshape")
                    }
                    
                }
                ToolbarItemGroup(placement: .topBarTrailing){
                        Button(action: {
                            print("Sort Options")
                        }){
                            Image(systemName: "ellipsis.circle")
                        }
                        
                        NavigationLink(destination: CreateRoutePage()){
                            Image(systemName: "map.fill")
                            Text("New").bold()
                        }.buttonStyle(.bordered)
                }
            })
        }.onAppear(perform: addExampleData).enableInjection()
    }
}

#Preview {
    MainView()
}

//
//  MainView.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import SwiftUI
import SwiftData



struct RouteListView: View {
    @Query var routes: [Route]
    @Environment(\.modelContext) var modelContext
        
    init(sort: SortDescriptor<Route>) {
        _routes = Query(sort: [sort])
    }

    var body: some View {
        if (routes.isEmpty){
            VStack {
                Image(systemName: "map")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                Text("No routes created yet")
                    .foregroundColor(.gray)
                    .padding(.vertical, 10)
                NavigationLink(destination: CreateRoutePage()){
//                    Image(systemName: "map.fill")
                    Text("Create a Route").bold()
                }.buttonStyle(.bordered)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        else{
            List {
                ForEach(routes, id: \.id) { route in
                    NavigationLink(destination: RouteDetailView(routeID: route.persistentModelID)){
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
                                withAnimation {
                                    modelContext.delete(route);
                                }
                                print("Delete")
                            }){
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        })}
                }
                .padding()
            }.animation(.easeOut, value: routes).listStyle(.inset)
        }
    }
}


enum E_SortKey: String {
    case creationDate
    case title
}


struct MainView: View {
    @ObserveInjection var inject
    
    @Query var routes: [Route]
    @Environment(\.modelContext) var modelContext
    @State private var sortOrder = SortDescriptor(\Route.creationDate, order: .reverse)
//    @State private var sortKey: KeyPath<Route, Any> = \Route.title
    @State private var sortKey: E_SortKey = .creationDate
    @State private var sortDirection: SortOrder = .reverse
    @State private var isSettingsPresented = false
    
    var body: some View {
        @ObserveInjection var inject

        NavigationStack {
            RouteListView(sort: sortOrder)
    Text("")
    .navigationTitle("Routes")
    .toolbar(content: {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                isSettingsPresented.toggle()
            }){
                Image(systemName: "gearshape")
            }.sheet(isPresented: $isSettingsPresented) {
                SettingsView(isPresented: $isSettingsPresented)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing){
            Menu {
                Picker(selection: $sortKey, label: Text("Sort By")) {
                    Text("Date Created").tag(E_SortKey.creationDate)
                    Text("Title").tag(E_SortKey.title)
                }.onChange(of: sortKey) {
                    if (sortKey == E_SortKey.creationDate){
                        sortOrder = SortDescriptor(\.creationDate, order: sortDirection)
                    }
                    else{
                        sortOrder = SortDescriptor(\.title, order: sortDirection)
                    }
                }
                
                Picker(selection: $sortDirection, label: Text("Direction")) {
                    if (sortKey == E_SortKey.creationDate){
                        Text("Newest First").tag(SortOrder.reverse)
                        Text("Oldest First").tag(SortOrder.forward)
                    }
                    else{
                        Text("Forwards").tag(SortOrder.forward)
                        Text("Reverse").tag(SortOrder.reverse)
                    }
                }.onChange(of: sortDirection) {
                    if (sortKey == E_SortKey.creationDate){
                        sortOrder = SortDescriptor(\.creationDate, order: sortDirection)
                    }
                    else{
                        sortOrder = SortDescriptor(\.title, order: sortDirection)
                    }
                }
            }
            label: {
                Label("Sort Options", systemImage: "ellipsis.circle")
            }
                
            if (!routes.isEmpty){
                NavigationLink(destination: CreateRoutePage()){
                    Image(systemName: "map.fill")
                    Text("New").bold()
                }.buttonStyle(.bordered)
            }
        }
    })
        }.enableInjection()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Route.self, configurations: config)

    return MainView()
        .modelContainer(container)
}

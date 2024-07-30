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
                                modelContext.delete(route);
                                print("Delete")
                            }){
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        })}
                }
                .padding()
            }
            .listStyle(.inset)
        }
    }
}




struct MainView: View {
    @ObserveInjection var inject
    
    @Query var routes: [Route]
    @Environment(\.modelContext) var modelContext
    
//    func addExampleData() {
//        if(routes.isEmpty){
//            for route in exampleRouteArray {
//                modelContext.insert(route);
//            }
//        }
//    }
    
//    enum SortOptions {
//        case title
//        case creationDate
//        
//        var description : String {
//          switch self {
//              case .title: return "Title"
//              case .creationDate: return "Creation Date"
//          }
//        }
//        
//        var routeProp : Any {
//            switch self {
//                case .title: return \Route.title
//                case .creationDate: return \Route.creationDate
//            }
//        }
//    }
//    
//    enum SortDirection {
//        case forwards
//        case reverse
//        
//        var description : String {
//          switch self {
//              case .forwards: return "Forwards"
//              case .reverse: return "Reverse"
//          }
//        }
//    }
//    
//    @State private var sortOption: SortOptions = .creationDate;
//    @State private var sortDirection: SortDirection = .reverse;
    
//    @State private var sortDirection = SortOrder.reverse
    @State private var sortOrder = SortDescriptor(\Route.creationDate, order: .reverse)

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
                    Menu {
                        Picker(selection: $sortOrder, label: Text("Sorting options")) {
                            Text("Date Created").tag(SortDescriptor(\Route.creationDate, order: .reverse))
                            Text("Title").tag(SortDescriptor(\Route.title))
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
//                    Menu("Direction") {
//                        Picker(selection: $sortDirection, label: Text("Sorting direction")) {
//                            Text("Forwards").tag(SortOrder.forward)
//                            Text("Reverse").tag(SortOrder.reverse)
//                        }
//                    }
                }
                label: {
                    Label("Sort", systemImage: "ellipsis.circle")
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

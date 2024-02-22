//
//  MainView.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import SwiftUI

struct MainView: View {
    @ObserveInjection var inject

    var body: some View {
        @ObserveInjection var inject

        NavigationView {
                    List {
                        ForEach(routes, id: \.self) { route in
                            //                    NavigationLink(destination: nil) { // RouteDetailView(route: route)
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
                            }
                            //                    }
                }
                .padding()
                .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                    Button(action: {
                        print("Delete")
                    }){
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                })
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
        }.enableInjection()
    }
}

#Preview {
    MainView()
}

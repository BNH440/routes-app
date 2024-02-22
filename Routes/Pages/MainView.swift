//
//  MainView.swift
//  Routes
//
//  Created by Blake Haug on 2/21/24.
//

import SwiftUI

struct MainPage: View {
    var body: some View {
        NavigationView {
                    List {
                        Section.init {
                            HStack {
                                Text("Routes")
                                    .font(.largeTitle.bold())
                                
                                Spacer()
                                
                                Button(action: {
                                    print("New")
                                }){
//                                    Image(systemName: "plus").bold().clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                    Label("New", systemImage: "plus").bold()
                                }
                                .buttonStyle(.bordered)
                                
                            }
                        }
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
                                
                                //                            StatusIndicator(status: todo.status)
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
            .navigationBarHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        print("Create Route")
//                    }){
//                        Label("Create Route", systemImage: "plus.square.fill.on.square.fill")
//                    }
//                    .buttonStyle(.bordered)
//                    
//                }
//            }
        }
    }

}

#Preview {
    MainPage()
}

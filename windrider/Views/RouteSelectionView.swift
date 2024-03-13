//
//  RouteSelectionView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 08/03/2024.
//

import SwiftUI
import SwiftData

struct RouteSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var paths: [CyclingPath]
    @Binding var selectedPath: CyclingPath?
    @Binding var isRouteSelectionViewPresented: Bool
    
    var body: some View {
        NavigationStack{
            
            List(selection: $selectedPath) {
                ForEach(paths, id: \.id) { route in
                    Button(action: {
                        selectedPath = route
                        isRouteSelectionViewPresented = false
                        
                    }) {
                        HStack{
                            Text(route.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    let index = indexSet.first!
                    let route = paths[index]
                    modelContext.delete(route)
                  
                })
            }
            .navigationTitle("Select Route")
        }
    }
}


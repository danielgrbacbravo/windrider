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
			List {
				ForEach(paths, id: \.id) { route in
					HStack{
						Text(route.name).font(.headline).tint(.primary)
						Spacer()
						
						if selectedPath == route {
							Image(systemName:"checkmark").foregroundStyle(.green)
						} else {
							Image(systemName:"chevron.right").onTapGesture {
								selectedPath = route
								isRouteSelectionViewPresented = false
							}
						}
						if route.isFavorite {
							Image(systemName: "star.fill") .onTapGesture {
								route.isFavorite = false
							}.foregroundStyle(.yellow)
						} else {
							Image(systemName: "star").onTapGesture {
								route.isFavorite = true
							}.foregroundStyle(.yellow)
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

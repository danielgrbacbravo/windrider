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
	@Binding var polylineSegements: [PolylineSegement]?
	@Binding var isRouteSelectionViewPresented: Bool
	@State var selectedFileURL: URL?
	@State var isPickerPresented = false
	@State var isEditViewPresented = false
	
	
	var body: some View {
		
		NavigationStack{
			List {
				ForEach(paths, id: \.id) { route in
					HStack{
						Text(route.name).font(.headline).tint(.primary)
						Spacer()
						
						if selectedPath != nil && selectedPath?.id.uuidString == route.id.uuidString{
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
					
					if selectedPath?.id == route.id {
						selectedPath = nil
					}
					
					selectedPath = ContentView.getDefaultPath(for: paths)
					
					polylineSegements?.removeAll()
					
				})
			}
			.navigationTitle("Select Route")
			.toolbar {
				
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						// open up GPX file manager
						isPickerPresented.toggle()
					} label: {
						
						Image(systemName: "plus")
						
					}.sheet(isPresented: $isPickerPresented) {
						DocumentPicker(selectedPath: $selectedPath)
							.ignoresSafeArea()
					}
				}
			}
			.toolbar{
				ToolbarItem(placement: .topBarTrailing) {
					Button{
						if Binding($selectedPath)?.wrappedValue != nil{
							isEditViewPresented.toggle()
						}

					}label: {
						Image(systemName:"slider.horizontal.3")
					}.sheet(isPresented: $isEditViewPresented) {
						EditPathView(selectedPath: $selectedPath, isPresented: $isEditViewPresented)
					}
				}
			}
		}
	}
	
	
}

//
//  EditPathView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 17/03/2024.
//

import Foundation
import  SwiftUI

struct EditPathView: View {
	@Binding var selectedPath: CyclingPath?
	@Binding var isPresented: Bool
	var body: some View {
		
		NavigationStack{
			List{
				TextField("insert text", text: Binding($selectedPath)!.name)
			}
		}
	}
}


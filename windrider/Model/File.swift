//
//  File.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 07/03/2024.
//

import Foundation
import SwiftData
struct previewContainer {
    let container: ModelContainer!
    init(_ types: [any PersistentModel.Type], isStoredInMemoryOnly: Bool = true) {
        let schema = Schema(types)
        let config = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        self.container = try! ModelContainer(for:schema, configurations: config)
    }
}

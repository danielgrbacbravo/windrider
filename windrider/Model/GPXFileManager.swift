import SwiftUI
import UIKit
import UniformTypeIdentifiers
import CoreLocation
import SwiftData

struct DocumentPicker: UIViewControllerRepresentable {
	@Environment(\.modelContext) public var modelContext
	public var filePath: URL?
	@Binding public var selectedPath: CyclingPath?


	func makeCoordinator() -> Coordinator {
		Coordinator(self, modelContext: modelContext, selectedPath: $selectedPath)
	}

	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		let supportedTypes: [UTType] = [UTType.data, UTType.content]
		let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
		picker.delegate = context.coordinator
		picker.allowsMultipleSelection = false
		return picker
	}

	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
		// No update necessary
	}

	class Coordinator: NSObject, UIDocumentPickerDelegate {
		var parent: DocumentPicker
		var modelContext: ModelContext
		@Binding var selectedPath: CyclingPath?

		init(_ parent: DocumentPicker, modelContext: ModelContext, selectedPath: Binding<CyclingPath?>) {
			self.parent = parent
			self.modelContext = modelContext
			self._selectedPath = selectedPath
		}

		func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
			guard let selectedFileURL = urls.first else {
				return
			}
			parent.filePath = selectedFileURL
			
			//process and parse the gpx file
			do{
			let data = try Data(contentsOf: selectedFileURL)
				let parser = GPXParser()
				
				let path = parser.parseGPXtoCyclePath(data,url: selectedFileURL)
				modelContext.insert(path)
				selectedPath = path
				
				
				
			} catch {
				print("Failed to read data from file: \(error)")
			}
			
			
			print(selectedFileURL.absoluteString)
		}
	}
}

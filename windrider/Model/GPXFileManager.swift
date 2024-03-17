import SwiftUI
import UIKit
import UniformTypeIdentifiers
import CoreLocation
import SwiftData

struct DocumentPicker: UIViewControllerRepresentable {
	@Binding var filePath: URL?
	@Environment(\.modelContext) private var modelContext

	func makeCoordinator() -> Coordinator {
		Coordinator(self, modelContext: modelContext)
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

		init(_ parent: DocumentPicker, modelContext: ModelContext) {
			self.parent = parent
			self.modelContext = modelContext
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
				
			} catch {
				print("Failed to read data from file: \(error)")
			}
			
			
			print(selectedFileURL.absoluteString)
		}
	}
}

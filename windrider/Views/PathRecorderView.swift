//
//  PathRecorderView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 14/03/2024.
//

import SwiftUI
import SwiftData
import CoreLocation

struct PathRecorderView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPathRecorderViewPresented: Bool
    @Binding var cyclingPathRecorder: CyclingPathRecorder
    @State var isRecording: Bool = false
    @State var currentPath: [CLLocationCoordinate2D]?
    @State var authorizationStatus: CLAuthorizationStatus?
    var body: some View {
        NavigationStack{
            VStack{
                if isRecording {
                    
                    Image(systemName: "record.circle")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .padding()
                    
                   
                } else {
                    Text("Record a new cycling path")
                        .font(.title)
                        .bold()
                        .padding()
                }
                
                if authorizationStatus == .denied {
                    Text("Location access denied")
                        .font(.title)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                if authorizationStatus == .notDetermined {
                    HStack{
                        Text("Location access not determined")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .background(.yellow)
                    .padding()
                }
                
                if authorizationStatus == .restricted {
                    Text("Location access restricted")
                        .font(.title)
                        .foregroundStyle(.yellow)
                        .padding()
                }
                
                if authorizationStatus == .authorizedWhenInUse {
                    Text("Location access authorized")
                        .font(.title)
                        .foregroundStyle(.green)
                        .padding()
                }
                
                
                HStack{
                    Button(action: {
                        isRecording = true
                        authorizationStatus = cyclingPathRecorder.startRecordingPath(name: "test")
                    }) {
                        
                        
                        Image(systemName: "record.circle")
                                                .padding()
                                                .foregroundColor(.red)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())

                            
                    }
                    
                    Button(action: {
                        isRecording = false
                        guard let path = cyclingPathRecorder.stopRecordingPath() else { return }
                        modelContext.insert(path)
                    }) {
                        Image(systemName: "stop.fill")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())             }
                    
                    Button {
                        currentPath = cyclingPathRecorder.getCurrentPath()
                        
                    } label: {
                        Image(systemName: "arrow.right.circle")
                                                .padding()
                                                .foregroundColor(.primary)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                    }
                }.padding()
                
                
              
                    
                if currentPath != nil {
                    ForEach(Array((currentPath?.enumerated())!), id: \.offset) { index , object in
                        Text("\(index): \(object.latitude), \(object.longitude)")
                    }
                }
      
            }
            
        }
    }
}

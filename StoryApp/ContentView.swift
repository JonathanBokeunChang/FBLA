//
//  ContentView.swift
//  StoryApp
//
//  Created by Jonathan Chang on 1/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @EnvironmentObject var storyManager: StoryManager
    @State private var showResults = false

    var body: some View {
        NavigationView {
            ZStack {
                StoryView(cameraManager: cameraManager, showResults: $showResults)
                    .environmentObject(storyManager)
                
                CameraPreviewView(cameraManager: cameraManager)
                    .frame(width: 200, height: 300)
                    .cornerRadius(10)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                    .position(x: UIScreen.main.bounds.width - 120, y: 100)
            }
            .fullScreenCover(isPresented: $showResults) {
                FaceResultsView(faces: cameraManager.detectedFaces, videoMetadata: cameraManager.videoMetadata)
            }
        }
    }
}

#Preview {
    ContentView()
}

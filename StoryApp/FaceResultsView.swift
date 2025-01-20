import SwiftUI

struct FaceResultsView: View {
    let faces: [Face]
    let videoMetadata: VideoMetadata?
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Text("**Please wait for the machine learning model to determine emotions...**")
                            .padding(30)
                            .background(.white.opacity(0.5))
                            .foregroundStyle(.blue)
                    }
                    .foregroundColor(.blue)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    
                } else {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Text("**Please wait for the machine learning model to determine emotions...**")
                            .padding(30)
                            .background(.white.opacity(0.5))
                            .foregroundStyle(.blue)
                    }
                    .foregroundColor(.blue)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    
                    ForEach(faces.indices, id: \.self) { index in
                        faceDetailView(for: faces[index], at: index)
                    }
                    
                    if let metadata = videoMetadata {
                        videoMetadataView(metadata: metadata)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }

    private var headerView: some View {
        Text("Face Detection Results")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }

    private func faceDetailView(for face: Face, at index: Int) -> some View {
        let dominantEmotion = face.emotions.max(by: { $0.confidence < $1.confidence })
        let backgroundColor = getColorForEmotion(dominantEmotion?.type ?? "CALM")
        
        return VStack {
            HStack {
                Text("Time \(Double(index) * 0.5) Seconds")
                    .font(.headline)
                Spacer()
                Text(dominantEmotion?.type ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(Color.white)
                    .padding(5)
                    .background(backgroundColor)
                    .cornerRadius(5)
            }
            .padding()
            
            Text("Confidence: \(face.confidence, specifier: "%.2f")%")
                .padding(.bottom, 5)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    private func videoMetadataView(metadata: VideoMetadata) -> some View {
        VStack(alignment: .leading) {
            Text("Video Metadata")
                .font(.headline)
                .padding(.bottom, 5)
            Text("Codec: \(metadata.codec ?? "N/A")")
            Text("Duration: \(metadata.durationMillis ?? 0) ms")
            Text("Frame Rate: \(metadata.frameRate ?? 0) fps")
            Text("Resolution: \(metadata.frameWidth ?? 0)x\(metadata.frameHeight ?? 0)")
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    private func getColorForEmotion(_ emotion: String) -> Color {
        switch emotion {
        case "HAPPY":
            return Color.green.opacity(0.3)
        case "SAD":
            return Color.blue.opacity(0.3)
        case "ANGRY":
            return Color.red.opacity(0.3)
        case "SURPRISED":
            return Color.yellow.opacity(0.3)
        case "CALM":
            return Color.gray.opacity(0.3)
        case "DISGUSTED":
            return Color.purple.opacity(0.3)
        case "CONFUSED":
            return Color.orange.opacity(0.3)
        case "FEAR":
            return Color.black.opacity(0.3)
        default:
            return Color.white
        }
    }
} 

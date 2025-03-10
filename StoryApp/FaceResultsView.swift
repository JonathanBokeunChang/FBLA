import SwiftUI

struct FaceResultsView: View {
    let faces: [Face]
    let videoMetadata: VideoMetadata?
    let dominantEmotions: [String]
    @State private var isLoading: Bool = true
    @State private var showReportView: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                
                if isLoading {
                    loadingView
                } else {
                    emotionsTimelineView
                    
                    if let metadata = videoMetadata {
                        videoMetadataView(metadata: metadata)
                    }
                    
                    Button("Generate Report") {
                        showReportView = true
                    }
                    .padding()
                    .sheet(isPresented: $showReportView) {
                        let lengthPlayed = dominantEmotions.count * 5 // Assuming each segment is 5 seconds
                        let storyInfo = getStoryInfo(for: "ending_justice") // Replace with actual logic to get the ending identifier

                        ReportView(
                            faces: faces,
                            videoMetadata: videoMetadata,
                            dominantEmotions: dominantEmotions,
                            storyTitle: storyInfo.title,
                            storyDescription: storyInfo.description
                        )
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Wait for emotions to be processed
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

    private var loadingView: some View {
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
    }

    private var emotionsTimelineView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Emotional Timeline")
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(dominantEmotions.indices, id: \.self) { index in
                HStack {
                    Text("0:\(index * 5)-0:\((index + 1) * 5)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(dominantEmotions[index])
                        .padding(8)
                        .background(getColorForEmotion(dominantEmotions[index]))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
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

    private func getStoryInfo(for endingIdentifier: String) -> (title: String, description: String) {
        let storyEndings = [
            "ending_justice": ("Justice Served", "You rescue the businessman, but it's revealed he was hiding his crimes. The town is left divided, but justice prevails."),
            "ending_confession": ("Family's Fall", "The wife admits she staged the disappearance to protect their empire. The family's downfall shakes the town, and their legacy crumbles."),
            "ending_scheme": ("The Great Escape", "The disappearance was staged to escape debts. You expose the scam, but the businessman vanishes, leaving chaos behind."),
            "ending_discovery": ("Hidden Truth", "The map leads to a hideout with proof of the family's plot. Their exposure brings scandal, but you're offered a major case in the city."),
            // Add more mappings as needed
        ]
        
        return storyEndings[endingIdentifier] ?? ("Unknown Ending", "No description available.")
    }
} 

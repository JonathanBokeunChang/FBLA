import SwiftUI

struct WelcomeView: View {
    @State private var isTextVisible = false
    @State private var showMainStory = false
    @State private var showResults = false
    @State private var showHelp = false
    @StateObject private var cameraManager = CameraManager()
    
    // New state variables for genre selection
    @State private var selectedGenre: String = "Default"
    let genres = ["Default", "Horror", "Thriller", "Cozy"]

    var body: some View {
        ZStack {
            // Same noir background as StoryView
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 0.1, green: 0.1, blue: 0.2, opacity: 1),
                    Color(.sRGB, red: 0.2, green: 0.2, blue: 0.3, opacity: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Rain effect
            GeometryReader { geometry in
                ForEach(0..<50) { _ in
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 2, height: 10)
                        .offset(x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height))
                }
            }
            
            VStack(spacing: 40) {
                // Badge icon
                Image(systemName: "shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red.opacity(0.8))
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 150, height: 150)
                    )
                    .shadow(color: .red.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 20) {
                    Text("WELCOME, DETECTIVE")
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("CASE FILE: THE MIDNIGHT CIPHER")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.red.opacity(0.8))
                }
                .opacity(isTextVisible ? 1 : 0)
                
                VStack(spacing: 15) {
                    
                    Text("Your Job is to investigate the case \n by choosing between two dire options. \n Your face will be recorded throughout the \n investigation to determine your emotions.\n First, pick a story mode")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                    
                }
                .opacity(isTextVisible ? 1 : 0)
                
                // Genre Picker
                Picker("Select Genre", selection: $selectedGenre) {
                    ForEach(genres, id: \.self) { genre in
                        Text(genre).tag(genre)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                VStack {
                    
                    
                    
                    Button("BEGIN INVESTIGATION") {
                        withAnimation(.spring()) {
                            showMainStory = true
                        }
                    }
                    .padding(.horizontal, 40)
                    .opacity(isTextVisible ? 1 : 0)
                }
                .padding()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showHelp = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                isTextVisible = true
            }
        }
        .fullScreenCover(isPresented: $showMainStory) {
            StoryView(cameraManager: cameraManager, showResults: $showResults)
                .onAppear {
                    StoryManager.shared.currentSceneId = selectedGenre // Set the current scene based on selected genre
                }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }

    private func generateStoryPart() {
        // Assuming you have a way to get the current story part
        let currentStoryPart = "This is the current story part." // Replace with actual story part
        let systemMessage = "Modify the following story part to fit the genre \(selectedGenre): \(currentStoryPart)"
        
        // Prepare the request to the GPT API
        let url = URL(string: "https://b3de-2601-8c-4a7e-3cd0-340f-2fbc-361c-5ab9.ngrok-free.app/gpt")! // Replace with your actual API URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["input": systemMessage]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Perform the API request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let generatedStoryPart = json["response"] as? String {
                // Use the generated story part in your StoryView
                DispatchQueue.main.async {
                    // Update your StoryView with the new story part
                    // For example, you might have a state variable in StoryView to hold the story part
                    // storyPart = generatedStoryPart
                }
            }
        }.resume()
    }
} 

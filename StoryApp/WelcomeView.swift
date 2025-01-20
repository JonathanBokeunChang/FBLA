import SwiftUI

struct WelcomeView: View {
    @State private var isTextVisible = false
    @State private var showMainStory = false
    @State private var showResults = false
    @StateObject private var cameraManager = CameraManager()

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
                    Text("A series of cryptic messages have surfaced.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.gray)
                    
                    Text("Time is running out.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.gray)
                }
                .opacity(isTextVisible ? 1 : 0)
                
                // Start button
                Button(action: {
                    withAnimation(.spring()) {
                        showMainStory = true
                    }
                }) {
                    Text("BEGIN INVESTIGATION")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.red.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.red.opacity(0.5), lineWidth: 1)
                                )
                                .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.horizontal, 40)
                .opacity(isTextVisible ? 1 : 0)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                isTextVisible = true
            }
        }
        .fullScreenCover(isPresented: $showMainStory) {
            StoryView(cameraManager: cameraManager, showResults: $showResults)
                .environmentObject(StoryManager.shared)
        }
    }
} 

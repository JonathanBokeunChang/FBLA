import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Help & Instructions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Text("1. Begin your investigation by selecting a story mode.")
            Text("2. Follow the prompts to make decisions and progress through the story.")
            Text("3. Your facial expressions will be recorded to analyze your emotions.")
            Text("4. Generate a report at the end to review your investigation.")
            
            Spacer()
        }
        .padding()
    }
} 
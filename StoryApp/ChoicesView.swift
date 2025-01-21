import SwiftUI

struct ChoicesView: View {
    let choices: [StoryChoice]
    let onChoiceSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Next Move, Detective")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.yellow)
                .padding(.bottom, 10)
            
            ForEach(choices) { choice in
                DetectiveChoiceButton(
                    choice: choice.title,
                    description: choice.description,
                    icon: choice.icon,
                    accentColor: .red.opacity(0.8),
                    action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onChoiceSelected(choice.nextSceneId)
                        }
                    }
                )
            }
        }
        .padding()
    }
}

struct DetectiveChoiceButton: View {
    let choice: String
    var description: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                // Icon with custom styling
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(accentColor)
                }
                
                // Choice text
                VStack(alignment: .leading, spacing: 4) {
                    Text(choice)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(accentColor.opacity(0.8))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accentColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}



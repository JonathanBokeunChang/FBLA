import SwiftUI

struct TransitionView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Processing your investigation...")
                    .font(.title)
                    .foregroundColor(.black)
                
                Text("Analyzing facial expressions...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            }
        }
        .interactiveDismissDisabled()
    }
} 

//
//  StoryApp.swift
//  StoryApp
//
//  Created by Jonathan Chang on 1/20/25.
//

import Foundation
import SwiftUI

@main
struct StoryApp: App {
    @StateObject private var storyManager = StoryManager.shared // Create an instance of StoryManager

    var body: some Scene {
        WindowGroup {
            WelcomeView() // Set WelcomeView as the initial view
                .environmentObject(storyManager) // Pass the storyManager as an environment object
        }
    }
}

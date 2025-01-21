import SwiftUI

struct StoryChoice: Identifiable {
    let id = UUID()
    let title: String
    var description: String
    let icon: String
    let nextSceneId: String
}

struct StoryScene {
    let id: String
    let title: String
    var description: String
    let evidencePercentage: Int
    let choices: [StoryChoice]
    let isEnding: Bool
}

class StoryManager: ObservableObject {
    static let shared = StoryManager()
    
    @Published var currentSceneId = "arrival"
    @Published var evidenceCollected = 0
    @Published var isLoadingDescription = false
    
    var currentScene: StoryScene {
        scenes[currentSceneId] ?? initialScene
    }
    
    private let initialScene = StoryScene(
        id: "arrival",
        title: "The Vanished Mogul",
        description: "A wealthy businessman has vanished under suspicious circumstances in this foggy small town. The mansion looms before you, its secrets waiting to be uncovered...",
        evidencePercentage: 0,
        choices: [
            StoryChoice(
                title: "Interview the Family",
                description: "Question the family members gathered in the parlor",
                icon: "person.2.fill",
                nextSceneId: "family_parlor"
            ),
            StoryChoice(
                title: "Search the Study",
                description: "Investigate the businessman's private office",
                icon: "magnifyingglass.circle.fill",
                nextSceneId: "office_study"
            )
        ],
        isEnding: false
    )
    
    @Published private var scenes: [String: StoryScene] = [:]
    
    private init() {
        setupScenes()
    }
    
    private func setupScenes() {
        scenes["arrival"] = initialScene
        
        // 2A. Family Parlor Branch
        scenes["family_parlor"] = StoryScene(
            id: "family_parlor",
            title: "Family Secrets",
            description: "The wife is tearful, but the son avoids eye contact. The tension in the room is palpable.",
            evidencePercentage: 20,
            choices: [
                StoryChoice(
                    title: "Confront the Son",
                    description: "Directly question his suspicious behavior",
                    icon: "person.fill.questionmark",
                    nextSceneId: "confront_son"
                ),
                StoryChoice(
                    title: "Reassure the Wife",
                    description: "Build trust through empathy",
                    icon: "heart.fill",
                    nextSceneId: "reassure_wife"
                )
            ],
            isEnding: false
        )
        
        // 2B. Office Study Branch
        scenes["office_study"] = StoryScene(
            id: "office_study",
            title: "Office Clues",
            description: "You find a torn note mentioning a meeting at the docks. Time is of the essence.",
            evidencePercentage: 20,
            choices: [
                StoryChoice(
                    title: "Decode the Note",
                    description: "Piece together the torn fragments",
                    icon: "doc.text.magnifyingglass",
                    nextSceneId: "decode_note"
                ),
                StoryChoice(
                    title: "Search Further",
                    description: "Look for more clues in the study",
                    icon: "folder.fill.badge.plus",
                    nextSceneId: "hidden_drawer"
                )
            ],
            isEnding: false
        )
        
        // 3A. Son's Slip-Up
        scenes["confront_son"] = StoryScene(
            id: "confront_son",
            title: "Son's Confession",
            description: "The son admits his father owed dangerous people money. The plot thickens.",
            evidencePercentage: 40,
            choices: [
                StoryChoice(
                    title: "Visit Loan Shark",
                    description: "Track down the local loan shark",
                    icon: "dollarsign.circle.fill",
                    nextSceneId: "loan_shark"
                ),
                StoryChoice(
                    title: "Check Records",
                    description: "Investigate financial records",
                    icon: "doc.text.fill",
                    nextSceneId: "financial_records"
                )
            ],
            isEnding: false
        )
        
        // 3B. Wife's Confession
        scenes["reassure_wife"] = StoryScene(
            id: "reassure_wife",
            title: "Wife's Revelation",
            description: "The wife reveals her husband had an affair. New leads emerge.",
            evidencePercentage: 40,
            choices: [
                StoryChoice(
                    title: "Find Mistress",
                    description: "Track down the mistress",
                    icon: "person.fill.questionmark",
                    nextSceneId: "mistress_investigation"
                ),
                StoryChoice(
                    title: "Search House",
                    description: "Look for evidence of the affair",
                    icon: "house.fill",
                    nextSceneId: "house_search"
                )
            ],
            isEnding: false
        )
        
        // 3C. Decoding the Note
        scenes["decode_note"] = StoryScene(
            id: "decode_note",
            title: "Hidden Message",
            description: "The note reveals a late-night meeting at the docks. Time is crucial.",
            evidencePercentage: 40,
            choices: [
                StoryChoice(
                    title: "Stake Out",
                    description: "Watch the docks at midnight",
                    icon: "eye.fill",
                    nextSceneId: "dock_stakeout"
                ),
                StoryChoice(
                    title: "Alert Police",
                    description: "Inform local authorities",
                    icon: "bell.fill",
                    nextSceneId: "police_involvement"
                )
            ],
            isEnding: false
        )
        
        // 3D. Hidden Drawer
        scenes["hidden_drawer"] = StoryScene(
            id: "hidden_drawer",
            title: "Locked Secret",
            description: "You find a locked drawer that might contain crucial evidence.",
            evidencePercentage: 40,
            choices: [
                StoryChoice(
                    title: "Force It",
                    description: "Break open the drawer",
                    icon: "hammer.fill",
                    nextSceneId: "forced_drawer"
                ),
                StoryChoice(
                    title: "Find Key",
                    description: "Search for the key",
                    icon: "key.fill",
                    nextSceneId: "search_key"
                )
            ],
            isEnding: false
        )
        
        // 4A. Loan Shark Confrontation
        scenes["loan_shark"] = StoryScene(
            id: "loan_shark",
            title: "Dangerous Deal",
            description: "The loan shark demands payment for information. Choose carefully.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Make Deal",
                    description: "Pay for information",
                    icon: "banknote.fill",
                    nextSceneId: "ending_scheme"
                ),
                StoryChoice(
                    title: "Threaten",
                    description: "Force the truth out",
                    icon: "exclamationmark.triangle.fill",
                    nextSceneId: "ending_justice"
                )
            ],
            isEnding: false
        )
        
        // 4B. Mistress Investigation
        scenes["mistress_investigation"] = StoryScene(
            id: "mistress_investigation",
            title: "The Other Woman",
            description: "The mistress claims innocence but mentions a mysterious meeting.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Rush to Docks",
                    description: "Head there immediately",
                    icon: "arrow.right.circle.fill",
                    nextSceneId: "ending_justice"
                ),
                StoryChoice(
                    title: "Press Further",
                    description: "Demand more details",
                    icon: "person.fill.questionmark",
                    nextSceneId: "ending_confession"
                )
            ],
            isEnding: false
        )
        
        // 4C. Dock Stakeout
        scenes["dock_stakeout"] = StoryScene(
            id: "dock_stakeout",
            title: "Midnight Watch",
            description: "You spot a shadowy figure leaving a boat. Time to act.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Follow Quietly",
                    description: "Trail them discreetly",
                    icon: "footprints.fill",
                    nextSceneId: "ending_scheme"
                ),
                StoryChoice(
                    title: "Confront",
                    description: "Approach directly",
                    icon: "person.fill.questionmark",
                    nextSceneId: "ending_justice"
                )
            ],
            isEnding: false
        )
        
        // 4D. Key Search
        scenes["search_key"] = StoryScene(
            id: "search_key",
            title: "Hidden Map",
            description: "A map found inside the drawer reveals a secret location.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Follow Map",
                    description: "Track the location",
                    icon: "map.fill",
                    nextSceneId: "ending_discovery"
                ),
                StoryChoice(
                    title: "Confront Family",
                    description: "Show your findings",
                    icon: "person.2.fill",
                    nextSceneId: "ending_confession"
                )
            ],
            isEnding: false
        )
        
        // Endings
        scenes["ending_justice"] = StoryScene(
            id: "ending_justice",
            title: "Justice Served",
            description: "You rescue the businessman, but it's revealed he was hiding his crimes. The town is left divided, but justice prevails.",
            evidencePercentage: 100,
            choices: [],
            isEnding: true
        )
        
        scenes["ending_confession"] = StoryScene(
            id: "ending_confession",
            title: "Family's Fall",
            description: "The wife admits she staged the disappearance to protect their empire. The family's downfall shakes the town, and their legacy crumbles.",
            evidencePercentage: 100,
            choices: [],
            isEnding: true
        )
        
        scenes["ending_scheme"] = StoryScene(
            id: "ending_scheme",
            title: "The Great Escape",
            description: "The disappearance was staged to escape debts. You expose the scam, but the businessman vanishes, leaving chaos behind.",
            evidencePercentage: 100,
            choices: [],
            isEnding: true
        )
        
        scenes["ending_discovery"] = StoryScene(
            id: "ending_discovery",
            title: "Hidden Truth",
            description: "The map leads to a hideout with proof of the family's plot. Their exposure brings scandal, but you're offered a major case in the city.",
            evidencePercentage: 100,
            choices: [],
            isEnding: true
        )
        
        // Financial Records Investigation
        scenes["financial_records"] = StoryScene(
            id: "financial_records",
            title: "Paper Trail",
            description: "The financial records reveal a complex web of debts and suspicious transactions.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Follow Money",
                    description: "Trace the transactions",
                    icon: "dollarsign.circle.fill",
                    nextSceneId: "ending_scheme"
                ),
                StoryChoice(
                    title: "Confront Family",
                    description: "Present the evidence",
                    icon: "person.2.fill",
                    nextSceneId: "ending_confession"
                )
            ],
            isEnding: false
        )
        
        // House Search Results
        scenes["house_search"] = StoryScene(
            id: "house_search",
            title: "Hidden Evidence",
            description: "You discover letters and photographs revealing a deeper conspiracy.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Investigate Further",
                    description: "Follow the new leads",
                    icon: "magnifyingglass.circle.fill",
                    nextSceneId: "ending_discovery"
                ),
                StoryChoice(
                    title: "Confront Wife",
                    description: "Show the evidence",
                    icon: "person.fill.questionmark",
                    nextSceneId: "ending_confession"
                )
            ],
            isEnding: false
        )
        
        // Police Involvement
        scenes["police_involvement"] = StoryScene(
            id: "police_involvement",
            title: "Official Investigation",
            description: "The police set up a sting operation based on your evidence.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Join Operation",
                    description: "Work with the police",
                    icon: "shield.fill",
                    nextSceneId: "ending_justice"
                ),
                StoryChoice(
                    title: "Independent Search",
                    description: "Continue alone",
                    icon: "person.fill",
                    nextSceneId: "ending_discovery"
                )
            ],
            isEnding: false
        )
        
        // Forced Drawer
        scenes["forced_drawer"] = StoryScene(
            id: "forced_drawer",
            title: "Broken Secret",
            description: "The forced drawer reveals damaging documents about the family.",
            evidencePercentage: 60,
            choices: [
                StoryChoice(
                    title: "Analyze Documents",
                    description: "Study the evidence",
                    icon: "doc.text.magnifyingglass",
                    nextSceneId: "ending_discovery"
                ),
                StoryChoice(
                    title: "Immediate Action",
                    description: "Act on the information",
                    icon: "arrow.right.circle.fill",
                    nextSceneId: "ending_justice"
                )
            ],
            isEnding: false
        )
    }
    
    func moveToScene(_ sceneId: String) {
        withAnimation {
            currentSceneId = sceneId
            if let scene = scenes[sceneId] {
                evidenceCollected = scene.evidencePercentage
            }
        }
    }
    
    func resetStory() {
        currentSceneId = "arrival"
        evidenceCollected = 0
    }
    
    func updateCurrentSceneDescription(with newDescription: String) {
        if var scene = scenes[currentSceneId] {
            scene.description = newDescription
            scenes[currentSceneId] = scene
        }
    }
    
    func fetchNewDescription(for genre: String) {
        isLoadingDescription = true
        
        let currentStoryPart = currentScene.description
        let systemMessage = "Modify this investigation story with this genre \(genre): \(currentStoryPart)"
        
        let url = URL(string: "https://96da-50-224-175-53.ngrok-free.app/gpt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["input": systemMessage]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoadingDescription = false
                }
                return
            }
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let generatedStoryPart = json["response"] as? String {
                DispatchQueue.main.async {
                    self.updateCurrentSceneDescription(with: generatedStoryPart)
                    self.isLoadingDescription = false
                }
            }
        }.resume()
    }
} 

import SwiftUI
import PDFKit

struct ReportView: View {
    @State private var includeFaces: Bool = true
    @State private var includeEmotions: Bool = true
    @State private var includeMetadata: Bool = true
    @State private var includeStoryDetails: Bool = true
    @State private var reportText: String = ""
    
    let faces: [Face]
    let videoMetadata: VideoMetadata?
    let dominantEmotions: [String]
    @State private var storyTitle: String
    @State private var storyDescription: String
    
    init(faces: [Face], videoMetadata: VideoMetadata?, dominantEmotions: [String], storyTitle: String, storyDescription: String) {
        self.faces = faces
        self.videoMetadata = videoMetadata
        self.dominantEmotions = dominantEmotions
        self._storyTitle = State(initialValue: storyTitle)
        self._storyDescription = State(initialValue: storyDescription)
    }
    
    var body: some View {
        VStack {
            Form {
                Toggle("Include Faces", isOn: $includeFaces)
                Toggle("Include Emotions", isOn: $includeEmotions)
                Toggle("Include Video Metadata", isOn: $includeMetadata)
                Toggle("Include Story Details", isOn: $includeStoryDetails)
                
                if includeStoryDetails {
                    TextField("Story Title", text: $storyTitle)
                    TextField("Story Description", text: $storyDescription)
                }
            }
            
            Button("Generate Report") {
                generateReport()
            }
            .padding()
            
            if !reportText.isEmpty {
                ScrollView {
                    Text(reportText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                }
            }
        }
        .navigationTitle("Customize Report")
    }
    
    func generateReport() {
        // Collect data based on user selections
        var reportData = [String]()
        
        if includeStoryDetails {
            reportData.append("Story Title: \(storyTitle)")
            reportData.append("Story Description: \(storyDescription)")
        }
        
        if includeFaces {
            reportData.append("Faces Detected: \(faces.count)")
        }
        
        if includeEmotions {
            reportData.append("Dominant Emotions: \(dominantEmotions.joined(separator: ", "))")
        }
        
        if includeMetadata, let metadata = videoMetadata {
            reportData.append("Video Metadata: Codec: \(metadata.codec), Duration: \(metadata.durationMillis) ms, Frame Rate: \(metadata.frameRate) fps, Resolution: \(metadata.frameWidth)x\(metadata.frameHeight)")
        }
        
        // Update the report text
        reportText = reportData.joined(separator: "\n")
    }
    
    func createPDFPage(with text: String) -> PDFPage? {
        // Create a page with a standard size
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // 8.5 x 11 inches
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            text.draw(in: pageRect.insetBy(dx: 20, dy: 20), withAttributes: attributes)
        }
        
        // Create a PDFDocument from the data and return the first page
        if let document = PDFDocument(data: data) {
            return document.page(at: 0)
        }
        
        return nil
    }
    
    func savePDF(_ document: PDFDocument) {
        // Get the documents directory path
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pdfPath = documentsPath.appendingPathComponent("Report.pdf")
        
        // Write the PDF document to the file
        if document.write(to: pdfPath) {
            print("PDF saved successfully at \(pdfPath)")
        } else {
            print("Failed to save PDF.")
        }
    }
}
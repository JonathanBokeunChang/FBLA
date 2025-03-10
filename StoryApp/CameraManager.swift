import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var detectionResults: String = ""
    @Published var detectedFaces: [Face] = []
    @Published var videoMetadata: VideoMetadata?
    @Published var showFaceDetails: Bool = false
    @Published var dominantEmotions: [String] = []  // Array to store dominant emotions for each 10s segment
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return _previewLayer
    }
    private var _previewLayer: AVCaptureVideoPreviewLayer?
    private var currentJobId: String?
    var currentRecordingPath: URL?
    
    private var recordingTimer: Timer?
    private var currentSegment = 0
    
    private var activeUploads: Set<String> = []
    
    override init() {
        super.init()
        setupCamera()
        startSession()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Error setting up camera input.")
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            print("Could not add video input.")
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput, captureSession?.canAddOutput(videoOutput) == true {
            captureSession?.addOutput(videoOutput)
        } else {
            print("Could not add video output.")
        }
        
        _previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        _previewLayer?.videoGravity = .resizeAspectFill
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            print("Camera session started.")
        }
    }
    
    private func getUniqueVideoPath() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        return documentsPath.appendingPathComponent("recording-\(timestamp).mp4")
    }
    
    func startRecording() {
        startNewSegment()
    }
    
    private func startNewSegment() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("video_segment_\(currentSegment)_\(timestamp).mov")
        currentRecordingPath = outputPath
        videoOutput?.startRecording(to: outputPath, recordingDelegate: self)
        isRecording = true
        
        // Set timer for 5 seconds instead of 10
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.handleSegmentComplete()
        }
    }
    
    private func handleSegmentComplete() {
        guard isRecording else { return }
        
        videoOutput?.stopRecording()
        isRecording = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let videoPath = self.currentRecordingPath,
               let fileAttributes = try? FileManager.default.attributesOfItem(atPath: videoPath.path),
               let fileSize = fileAttributes[.size] as? NSNumber,
               fileSize.intValue > 0 {
                
                print("Segment \(self.currentSegment) recorded successfully, size: \(fileSize.intValue) bytes")
                self.uploadCurrentSegment()
                
                // Start next segment after initiating upload
                self.currentSegment += 1
                self.startNewSegment()
            } else {
                print("Error: Segment \(self.currentSegment) file is invalid or empty")
                self.currentSegment += 1
                self.startNewSegment()
            }
        }
    }
    
    private func uploadCurrentSegment() {
        guard let videoPath = currentRecordingPath else { return }
        print("Uploading segment \(currentSegment) from path: \(videoPath)")
        
        // Create a local copy of the video file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let segmentCopyPath = FileManager.default.temporaryDirectory.appendingPathComponent("segment_\(currentSegment)_\(timestamp).mov")
        
        do {
            try FileManager.default.copyItem(at: videoPath, to: segmentCopyPath)
            
            uploadVideo(fileURL: segmentCopyPath) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.processSegmentResponse(response)
                    // Clean up the copy after successful upload
                    try? FileManager.default.removeItem(at: segmentCopyPath)
                case .failure(let error):
                    print("Segment \(self?.currentSegment ?? 0) upload error: \(error)")
                }
            }
        } catch {
            print("Error copying segment file: \(error)")
        }
    }
    
    private func processSegmentResponse(_ response: FaceDetectionResponse) {
        // Find the dominant emotion for this segment
        let allEmotions = response.faces.compactMap { faceWrapper -> String? in
            let emotions = faceWrapper.face.emotions
            return emotions.max(by: { $0.confidence < $1.confidence })?.type
        }
        
        // Get most frequent emotion
        let dominantEmotion = findMostFrequent(emotions: allEmotions)
        DispatchQueue.main.async {
            self.dominantEmotions.append(dominantEmotion ?? "UNKNOWN")
        }
    }
    
    private func findMostFrequent(emotions: [String]) -> String? {
        let counts = emotions.reduce(into: [:]) { counts, emotion in
            counts[emotion, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    func stopRecording() {
        // Stop current recording if active
        if isRecording {
            videoOutput?.stopRecording()
            isRecording = false
        }
        
        // Cancel any pending timer
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Stop the capture session
        captureSession?.stopRunning()
        
        // Clear the preview layer
        _previewLayer?.removeFromSuperlayer()
        _previewLayer = nil
        
        // Ensure the last segment is uploaded
        if let videoPath = currentRecordingPath {
            uploadCurrentSegment()
        }
        
        // Reset segment counter
        currentSegment = 0
        
        print("Camera session and recording stopped")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
            return
        }
        
        print("Recording finished successfully at: \(outputFileURL)")
        
        // Check if the file exists and its size
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: outputFileURL.path)
        if let fileSize = fileAttributes?[.size] as? NSNumber {
            print("Recorded video file size: \(fileSize.intValue) bytes")
        } else {
            print("Could not retrieve file size.")
        }
    }
    
    private func handleFaceDetectionResponse(_ response: FaceDetectionResponse) {
        DispatchQueue.main.async {
            self.detectionResults = "Detected \(response.faces.count) faces."
            self.detectedFaces = response.faces.map { $0.face }
            self.videoMetadata = response.videoMetadata
            self.showFaceDetails = true
            
            if response.faces.isEmpty {
                print("No faces detected.")
            } else {
                print("Detected \(response.faces.count) faces.")
            }
            print("Results received, navigating to FaceResultsView")
        }
    }
    
    func uploadVideo(fileURL: URL, completion: @escaping (Result<FaceDetectionResponse, Error>) -> Void) {
        let uploadId = UUID().uuidString
        activeUploads.insert(uploadId)
        
        let url = URL(string: "https://b3de-2601-8c-4a7e-3cd0-340f-2fbc-361c-5ab9.ngrok-free.app/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = fileURL.lastPathComponent
        let mimeType = "video/mp4"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        do {
            let videoData = try Data(contentsOf: fileURL)
            body.append(videoData)
        } catch {
            print("Error reading video file: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Perform the upload task asynchronously
        let task = URLSession.shared.uploadTask(with: request, from: body) { [weak self] data, response, error in
            defer {
                self?.activeUploads.remove(uploadId)
            }
            
            if let error = error {
                print("Upload \(uploadId) error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response received.")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                }
                return
            }
            
            print("HTTP Response Status Code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)))
                }
                return
            }
            
            guard let data = data else {
                print("No data received from upload response.")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            // Print the raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                if let response = try? JSONDecoder().decode(FaceDetectionResponse.self, from: data) {
                    let facesCount = response.faces.count
                    let duration = response.videoMetadata?.durationMillis ?? 0
                    let mainEmotion = response.faces.first?.face.emotions.max(by: { $0.confidence < $1.confidence })?.type ?? "unknown"
                    print("✅ Upload \(uploadId) complete - Faces: \(facesCount), Duration: \(duration)ms, Main emotion: \(mainEmotion)")
                }
            }
            
            // Parse the response to get the face detection results
            do {
                let faceDetectionResponse = try JSONDecoder().decode(FaceDetectionResponse.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    self?.handleFaceDetectionResponse(faceDetectionResponse)
                    completion(.success(faceDetectionResponse))
                }
            } catch {
                print("Error parsing upload response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

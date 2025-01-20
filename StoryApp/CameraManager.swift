import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var detectionResults: String = ""
    @Published var detectedFaces: [Face] = []
    @Published var videoMetadata: VideoMetadata?
    @Published var showFaceDetails: Bool = false
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return _previewLayer
    }
    private var _previewLayer: AVCaptureVideoPreviewLayer?
    private var currentJobId: String?
    var currentRecordingPath: URL?
    
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
        guard let videoOutput = videoOutput else {
            print("Video output is not available.")
            return
        }
        
        let videoPath = getUniqueVideoPath()
        currentRecordingPath = videoPath
        videoOutput.startRecording(to: videoPath, recordingDelegate: self)
        isRecording = true
        print("Started recording to: \(videoPath)")
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
        isRecording = false
        print("Stopped recording.")
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
        let url = URL(string: "https://07d4-2601-8c-4a7e-3cd0-7029-8fad-18b1-f6a7.ngrok-free.app/upload")!
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
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
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
                print("Raw response data: \(responseString)")
            }
            
            // Parse the response to get the face detection results
            do {
                let faceDetectionResponse = try JSONDecoder().decode(FaceDetectionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.handleFaceDetectionResponse(faceDetectionResponse)
                }
                completion(.success(faceDetectionResponse))
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

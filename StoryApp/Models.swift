import Foundation

struct FaceDetectionResponse: Codable {
    let faces: [FaceWrapper]
    let nextToken: String?
    let status: String?
    let videoMetadata: VideoMetadata?

    enum CodingKeys: String, CodingKey {
        case faces = "faces"
        case nextToken = "next_token"
        case status = "status"
        case videoMetadata = "video_metadata"
    }
}

struct FaceWrapper: Codable {
    let face: Face
    let timestamp: Int

    enum CodingKeys: String, CodingKey {
        case face = "Face"
        case timestamp = "Timestamp"
    }
}

struct Face: Codable {
    let ageRange: AgeRange
    let beard: Attribute
    let boundingBox: BoundingBox
    let confidence: Double
    let emotions: [Emotion]
    let eyeglasses: Attribute
    let eyesOpen: Attribute
    let gender: Gender
    let landmarks: [Landmark]
    let mouthOpen: Attribute
    let mustache: Attribute
    let pose: Pose
    let quality: Quality
    let smile: Attribute
    let sunglasses: Attribute

    enum CodingKeys: String, CodingKey {
        case ageRange = "AgeRange"
        case beard = "Beard"
        case boundingBox = "BoundingBox"
        case confidence = "Confidence"
        case emotions = "Emotions"
        case eyeglasses = "Eyeglasses"
        case eyesOpen = "EyesOpen"
        case gender = "Gender"
        case landmarks = "Landmarks"
        case mouthOpen = "MouthOpen"
        case mustache = "Mustache"
        case pose = "Pose"
        case quality = "Quality"
        case smile = "Smile"
        case sunglasses = "Sunglasses"
    }
}

struct AgeRange: Codable {
    let high: Int
    let low: Int

    enum CodingKeys: String, CodingKey {
        case high = "High"
        case low = "Low"
    }
}

struct Attribute: Codable {
    let confidence: Double
    let value: Bool

    enum CodingKeys: String, CodingKey {
        case confidence = "Confidence"
        case value = "Value"
    }
}

struct BoundingBox: Codable {
    let height: Double
    let left: Double
    let top: Double
    let width: Double

    enum CodingKeys: String, CodingKey {
        case height = "Height"
        case left = "Left"
        case top = "Top"
        case width = "Width"
    }
}

struct Emotion: Codable {
    let confidence: Double
    let type: String

    enum CodingKeys: String, CodingKey {
        case confidence = "Confidence"
        case type = "Type"
    }
}

struct Gender: Codable {
    let confidence: Double
    let value: String

    enum CodingKeys: String, CodingKey {
        case confidence = "Confidence"
        case value = "Value"
    }
}

struct Landmark: Codable {
    let type: String
    let x: Double
    let y: Double

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case x = "X"
        case y = "Y"
    }
}

struct Pose: Codable {
    let pitch: Double
    let roll: Double
    let yaw: Double

    enum CodingKeys: String, CodingKey {
        case pitch = "Pitch"
        case roll = "Roll"
        case yaw = "Yaw"
    }
}

struct Quality: Codable {
    let brightness: Double
    let sharpness: Double

    enum CodingKeys: String, CodingKey {
        case brightness = "Brightness"
        case sharpness = "Sharpness"
    }
}

struct VideoMetadata: Codable {
    let codec: String
    let colorRange: String
    let durationMillis: Int
    let format: String
    let frameHeight: Int
    let frameRate: Double
    let frameWidth: Int

    enum CodingKeys: String, CodingKey {
        case codec = "Codec"
        case colorRange = "ColorRange"
        case durationMillis = "DurationMillis"
        case format = "Format"
        case frameHeight = "FrameHeight"
        case frameRate = "FrameRate"
        case frameWidth = "FrameWidth"
    }
}
import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewControllerRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.layer.addSublayer(cameraManager.previewLayer!)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        cameraManager.previewLayer?.frame = uiViewController.view.bounds
        uiViewController.view.layoutIfNeeded()
    }
}
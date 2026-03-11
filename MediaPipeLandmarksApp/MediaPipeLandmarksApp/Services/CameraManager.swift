import AVFoundation
import UIKit

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer)
}

class CameraManager: NSObject {
    
    weak var delegate: CameraManagerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.example.MediaPipeLandmarks.sessionQueue")
    private let videoQueue = DispatchQueue(label: "com.example.MediaPipeLandmarks.videoQueue")
    
    private(set) var previewLayer: AVCaptureVideoPreviewLayer!
    
    override init() {
        super.init()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func setupCamera() {
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func configureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        // MediaPipe Tasks on iOS expects RGB/BGRA style pixel buffers for reliable live-stream inference.
        // Some devices default to YUV output if not specified, which can lead to preview-only behavior.
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        
        captureSession.commitConfiguration()
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraManager(self, didOutput: sampleBuffer)
    }
}

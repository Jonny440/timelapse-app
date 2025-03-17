//
//  CameraManager.swift
//  TimeLapseApp
//
//  Created by Z1 on 25.01.2025.
//
import UIKit
import Foundation
import AVFoundation
import AudioToolbox

class CameraManager: NSObject {
    var captureDevice: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    
    var backInput: AVCaptureDeviceInput!
    var frontInput: AVCaptureDeviceInput!
    var cameraQueue = DispatchQueue(label: "com.CapturingModelQueue")
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var minZoomScale: Float? = 1.0
    var maxZoomScale: Float? = 1.0
    
    var isTimeLapseOn = false
    var backCameraOn = true
    var isTorchOn = false
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoMaker = VideoMaker()
    var selectedIndex: Int? = UserDefaults.standard.integer(forKey: "saveOption")
    var folderURL: URL?
    var soundID: SystemSoundID = 0
    
    func startNewSession() {
        self.folderURL = createFolder(folderName: "Timelapse_\(Date().timeIntervalSince1970)")
    }
    
    func setupDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
                                                                    [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        guard let device = discoverySession.devices.first else {
            return nil
        }
        
        print(device.maxAvailableVideoZoomFactor)
        return device
    }
    
    func setupInput() {
        backCamera = setupDevice()
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

        guard let backCamera = backCamera, let frontCamera = frontCamera else { return }

        do {
            backInput = try AVCaptureDeviceInput(device: backCamera)
            guard captureSession.canAddInput(backInput) else { return }

            frontInput = try AVCaptureDeviceInput(device: frontCamera)
            guard captureSession.canAddInput(frontInput) else { return }
        } catch {
            fatalError("could not connect camera")
        }

        captureDevice = backCamera
        captureSession.addInput(backInput)
    }
    
    func setupOutput() {
        guard captureSession.canAddOutput(photoOutput) else {
            return
        }

        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality

        captureSession.addOutput(photoOutput)
    }
    
    func configureSession() {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }

            self.captureSession.beginConfiguration()

            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true

            self.setupInput()
            self.setupOutput()

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func switchCamera() {
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            captureDevice = frontCamera
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            captureDevice = backCamera
            backCameraOn = true
        }
    }

    func savePhotoToFolder(image: UIImage, folderURL: URL) {
        let fileName = "photo_\(Date().timeIntervalSince1970).jpeg"
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving photo: \(error)")
            }
        }
    }
    
    func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsURL.appendingPathComponent(folderName)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating folder: \(error)")
                return nil
            }
        }
        return folderURL
    }
    
    func deleteFolder(folderURL: URL) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: folderURL)
        } catch {
            print("Error deleting folder: \(error)")
        }
    }
}

//MARK: - Adding photos in array

extension CameraManager : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        autoreleasepool {
            guard let heifData = photo.fileDataRepresentation(), let image = UIImage(data: heifData)
            else { print("Failed to get heif data"); return }
            
            if selectedIndex == 1 {
                if let cgImage = image.cgImage {
                    videoMaker.newFrame(image: cgImage)
                } else {
                    print("Failed to get pngData")
                }
            } else if selectedIndex == 0, let folder = folderURL {
                savePhotoToFolder(image: image, folderURL: folder)
            }
        }
    }
    
    func playInvertedShutterSound() {
        if soundID == 0 {
            if let path = Bundle.main.path(forResource: "photoShutter2", ofType: "caf") {
                let url = URL(fileURLWithPath: path)
                AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesPlaySystemSound(soundID)
    }
}


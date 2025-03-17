//
//  MainViewModel.swift
//  TimeLapseApp
//
//  Created by Z1 on 15.02.2025.
//

import AVFoundation
import UIKit

class CameraViewModel {
    
    var cameraSettings = CameraSettings()
    var cameraManager = CameraManager()
    var isTimeLapseOn = false
    var isTorchOn = false
    var timer: Timer?
    var onUpdate: (() -> Void)?
    
    init() {
        cameraManager.configureSession()
        cameraManager.playInvertedShutterSound()
        configureSettings()
    }
    
    func setZoomFactor(_ factor: Float) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let zoomFactor = max(1.0, min(factor, Float(device.activeFormat.videoMaxZoomFactor)))
        
        do {
            try device.lockForConfiguration()
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                device.videoZoomFactor = CGFloat(zoomFactor)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error)")
        }
    }
    
    func configureSettings() {
        let isoIndex = cameraSettings.selectedISOIndex
        updateISO(at: isoIndex)
        
        let periodIndex = cameraSettings.selectedPeriodIndex
        updatePeriod(at: periodIndex)
        
        let shutterSpeedIndex = cameraSettings.selectedShutterSpeedIndex
        updateShutterSpeed(at: shutterSpeedIndex)
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        isTorchOn.toggle()
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = isTorchOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used: \(error)")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    func updateISO(at index: Int) {
        cameraSettings.selectedISO = cameraSettings.isoValues[index]
        configureDevice()
    }
    
    func updatePeriod(at index: Int) {
        cameraSettings.selectedPeriod = cameraSettings.periodValues[index]
    }
    
    func updateShutterSpeed(at index: Int) {
        cameraSettings.selectedShutterSpeed = cameraSettings.shutterSpeedValues[index]
        configureDevice()
    }
    
    func toggleTimeLapse() {
        if isTimeLapseOn == false {
            if UserDefaults.standard.integer(forKey: "saveOption") == 0 {
                cameraManager.startNewSession()
            } else {
                cameraManager.videoMaker.configure { success in
                    if success { print("video maker configured") }
                }
            }
            startTimeLapse()
        } else {
            stopTimeLapse()
        }
    }
    
    func startTimeLapse() {
        isTimeLapseOn = true
        timer = Timer.scheduledTimer(withTimeInterval: cameraSettings.selectedPeriod, repeats: true, block: { _ in
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            photoSettings.flashMode = self.cameraManager.isTorchOn ? .on : .off
            self.cameraManager.photoOutput.capturePhoto(with: photoSettings, delegate: self.cameraManager)
        })
    }
    
    func stopTimeLapse() {
        isTimeLapseOn = false
        timer?.invalidate()
        timer = nil
        if cameraManager.selectedIndex == 1 {
            cameraManager.videoMaker.finish()
        }
    }
    
    private func configureDevice() {
        guard let device = cameraManager.captureDevice else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = 1
            if device.isExposureModeSupported(.custom) {
                device.setExposureModeCustom(duration: CMTime(value: 1, timescale: CMTimeScale(self.cameraSettings.selectedShutterSpeed)), iso: self.cameraSettings.selectedISO)
            } else {
                print("Custom exposure mode not supported")
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to lock device for configuration: \(error)")
        }
        
    }
}

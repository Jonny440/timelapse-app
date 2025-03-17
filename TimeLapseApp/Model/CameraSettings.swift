//
//  Model.swift
//  TimeLapseApp
//
//  Created by Z1 on 15.02.2025.
//

import Foundation

struct CameraSettings {
    var isoValues: [Float] = [100, 200, 400, 800, 1600, 3200]
    var shutterSpeedValues: [Float] = [1024, 512, 256, 128, 64, 32]
    var periodValues: [Double] = [2, 4, 6, 8, 10]

    var selectedISO: Float = UserDefaults.standard.float(forKey: "selectedISO")
    var selectedShutterSpeed: Float = UserDefaults.standard.float(forKey: "selectedShutterSpeed")
    var selectedPeriod: Double = UserDefaults.standard.double(forKey: "selectedPeriod")

    var maxZoom: Float = 3
    var minZoom: Float = 1
    
    var selectedZoom: Float {
        get { UserDefaults.standard.float(forKey: "selectedZoom") }
        set { UserDefaults.standard.setValue(newValue, forKey: "selectedZoom") }
    }
    var selectedISOIndex: Int {
        isoValues.firstIndex(of: selectedISO) ?? 0
    }

    var selectedShutterSpeedIndex: Int {
        shutterSpeedValues.firstIndex(of: selectedShutterSpeed) ?? 0
    }

    var selectedPeriodIndex: Int {
        periodValues.firstIndex(of: selectedPeriod) ?? 0
    }
}

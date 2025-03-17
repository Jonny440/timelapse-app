//
//  ViewController.swift
//  TimeLapseApp
//
//  Created by Z1 on 24.01.2025.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var bottomView = BottomBarView()
    var topView = TopBarView()
    var viewModel = CameraViewModel()
    var topSegmentedControl = CustomSegmentedControl()
    var saveOptionSegmentControl = CustomSegmentedControl()
    
    var pickerArray = ["Zoom", "ISO", "Period", "Exposure", "Saving Option"]
    
    let zoomSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1.0
        slider.maximumValue = 2.0
        slider.value = 50
        slider.tintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let settingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .yellow
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isoPicker : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.tag = 1
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()

    var periodPicker : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.tag = 2
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()

    var shutterSpeedPicker : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.tag = 3
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        setupView()
        setupSegmentedControl()
        setupPreviewLayer()
        setupZoomSlider()
    }
    
    private func setupPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.cameraManager.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        updatePreviewLayerFrame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreviewLayerFrame()
    }

    
    private func bindModelView() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    private func updatePreviewLayerFrame() {
        guard let previewLayer = view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        
        let topHeight = topView.frame.maxY
        let bottomHeight = bottomView.frame.height
        let safeAreaHeight = view.bounds.height - topHeight - bottomHeight
        
        previewLayer.frame = CGRect(x: 0, y: topHeight, width: view.bounds.width, height: safeAreaHeight)
    }
    
    func updateUI() {
        bottomView.capturePhotoButton.backgroundColor = .lavanda
    }

    func setupView() {
        view.addSubviews(views: bottomView, topView, isoPicker, shutterSpeedPicker, periodPicker, settingLabel, zoomSlider)
        let pickers = [isoPicker, shutterSpeedPicker, periodPicker]
        pickers.forEach({
            $0.transform = CGAffineTransform(rotationAngle: -90 * (.pi/180))
            $0.delegate = self
            $0.dataSource = self
            $0.isHidden = true
        })
        bottomView.delegate = self
        
        isoPicker.selectRow(viewModel.cameraSettings.selectedISOIndex, inComponent: 0, animated: false)
        periodPicker.selectRow(viewModel.cameraSettings.selectedPeriodIndex, inComponent: 0, animated: false)
        shutterSpeedPicker.selectRow(viewModel.cameraSettings.selectedShutterSpeedIndex, inComponent: 0, animated: false)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22),
            
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            isoPicker.centerYAnchor.constraint(equalTo: bottomView.capturePhotoButton.centerYAnchor, constant: -70),
            isoPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            isoPicker.widthAnchor.constraint(equalToConstant: 40),
            isoPicker.heightAnchor.constraint(equalToConstant: view.bounds.width + 250),
            
            shutterSpeedPicker.centerYAnchor.constraint(equalTo: bottomView.capturePhotoButton.centerYAnchor, constant: -70),
            shutterSpeedPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterSpeedPicker.widthAnchor.constraint(equalToConstant: 40),
            shutterSpeedPicker.heightAnchor.constraint(equalToConstant: view.bounds.width + 250),
            
            periodPicker.centerYAnchor.constraint(equalTo: bottomView.capturePhotoButton.centerYAnchor, constant: -70),
            periodPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            periodPicker.widthAnchor.constraint(equalToConstant: 40),
            periodPicker.heightAnchor.constraint(equalToConstant: view.bounds.width + 250),
            
            zoomSlider.centerYAnchor.constraint(equalTo: bottomView.capturePhotoButton.centerYAnchor, constant: -70),
            zoomSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            zoomSlider.widthAnchor.constraint(equalToConstant: view.bounds.width - 50),
            zoomSlider.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func setupZoomSlider() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        let maxZoomFactor = Float(device.activeFormat.videoMaxZoomFactor)
        zoomSlider.minimumValue = 1.0
        zoomSlider.maximumValue = min(maxZoomFactor, 10.0) // Limit zoom to 10x max for usability
        zoomSlider.value = viewModel.cameraSettings.selectedZoom >= 1 ? viewModel.cameraSettings.selectedZoom : 1.0

        zoomSlider.addTarget(self, action: #selector(zoomSliderChanged), for: .valueChanged)
    }
    
    @objc func zoomSliderChanged(_ sender: UISlider) {
        viewModel.setZoomFactor(sender.value)
    }
}

//MARK: - Check the permissions
extension ViewController {
    func checkPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined: AVCaptureDevice.requestAccess(for: .video, completionHandler: { authorized in
            if !authorized { abort() }
        })
        case .authorized: print("capture permission is good")
        case .denied: abort()
        case .restricted: abort()
        default: fatalError("no permission to shoot photo")
        }
    }
}

//MARK: - BottomBarDelegate
extension ViewController: BottomBarDelegate {
    func toggleTorch() {
        viewModel.toggleTorch()
    }
    
    func switchCamera() {
        viewModel.cameraManager.switchCamera()
    }

    @objc func captureButtonPressed() {
        viewModel.cameraManager.selectedIndex = saveOptionSegmentControl.selectedIndex
        viewModel.toggleTimeLapse()
        if viewModel.isTimeLapseOn == false {
            showFileSavedAlert()
            UIView.animate(withDuration: 0.3) {
                self.bottomView.capturePhotoButton.backgroundColor = .white
                self.bottomView.capturePhotoButton.layer.borderColor = UIColor.lavanda.cgColor
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.bottomView.capturePhotoButton.backgroundColor = .lavanda
                self.bottomView.capturePhotoButton.layer.borderColor = UIColor.white.cgColor
            }
        }
        
    }

    private func showFileSavedAlert() {
        let alert = UIAlertController(
            title: "File Saved",
            message: "Your file has been saved in the Files app.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
}

//MARK: - Settin Segment
extension ViewController {
    private func setupSegmentedControl() {
        topSegmentedControl.options = [
            (title: nil, symbol: "magnifyingglass"),
            (title: "ISO", symbol: nil),
            (title: nil, symbol: "timer"),
            (title: nil, symbol: "plusminus.circle"),
            (title: nil, symbol: "opticaldisc.fill")
        ]
        topSegmentedControl.setStorageKey("topSegmentedControl")
        
        topSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        topSegmentedControl.selectionChanged = { [weak self] index in
            guard let self = self else { return }
            self.updatePickerVisibility(for: index)
        }
        
        view.addSubview(topSegmentedControl)
        NSLayoutConstraint.activate([
            topSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            topSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSegmentedControl.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20),
            topSegmentedControl.bottomAnchor.constraint(equalTo: topView.bottomAnchor)
        ])
        updatePickerVisibility(for: topSegmentedControl.selectedIndex)
        
        saveOptionSegmentControl.options = [
            (title: nil, symbol: "photo.stack"),
            (title: nil, symbol: "video.fill")
        ]
        saveOptionSegmentControl.setStorageKey("saveOption")
        saveOptionSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        saveOptionSegmentControl.selectionChanged = { [weak self] index in
            guard let self = self else { return }

            if self.saveOptionSegmentControl.selectedIndex != index {
                self.saveOptionSegmentControl.selectedIndex = index
            }
            
            UserDefaults.standard.set(index, forKey: "saveOption")
        }
        view.addSubview(saveOptionSegmentControl)
        
        NSLayoutConstraint.activate([
            saveOptionSegmentControl.centerYAnchor.constraint(equalTo: bottomView.capturePhotoButton.centerYAnchor, constant: -70),
            saveOptionSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveOptionSegmentControl.widthAnchor.constraint(equalToConstant: view.bounds.width),
            saveOptionSegmentControl.heightAnchor.constraint(equalToConstant: 40),
            
            settingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10),
            settingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func updatePickerVisibility(for index: Int) {
        let views = [zoomSlider, isoPicker, periodPicker, shutterSpeedPicker, saveOptionSegmentControl]
        views.forEach({
            $0.isHidden = true
        })
        settingLabel.text = pickerArray[index]
        views[index].isHidden = false
    }
}

//MARK: - Setting the picker
extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: return viewModel.cameraSettings.isoValues.count
        case 2: return viewModel.cameraSettings.periodValues.count
        case 3: return viewModel.cameraSettings.shutterSpeedValues.count
        default: return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.view.bounds.width / CGFloat(self.pickerArray.count)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: self.view.bounds.width / 3.5))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: self.view.bounds.width / 3.5))
        switch pickerView.tag {
        case 1: label.text = String(viewModel.cameraSettings.isoValues[row])
        case 2: label.text = String(viewModel.cameraSettings.periodValues[row])
        case 3: label.text = String(viewModel.cameraSettings.shutterSpeedValues[row])
        default: print("Nothing")
        }
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .yellow
        customView.addSubview(label)
        customView.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180))
        return customView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            let selectedISO = viewModel.cameraSettings.isoValues[row]
            viewModel.updateISO(at: row)
            UserDefaults.standard.set(selectedISO, forKey: "selectedISO")
        case 2:
            let selectedPeriod = viewModel.cameraSettings.periodValues[row]
            viewModel.updatePeriod(at: row)
            UserDefaults.standard.set(selectedPeriod, forKey: "selectedPeriod")
        case 3:
            let selectedShutterSpeed = viewModel.cameraSettings.shutterSpeedValues[row]
            viewModel.updateShutterSpeed(at: row)
            UserDefaults.standard.set(selectedShutterSpeed, forKey: "selectedShutterSpeed")
        default: return
        }
    }
}

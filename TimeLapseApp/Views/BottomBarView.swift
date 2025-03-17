//
//  BottomBarView.swift
//  TimeLapseApp
//
//  Created by Z1 on 24.01.2025.
//

import UIKit

protocol BottomBarDelegate {
    func captureButtonPressed()
    func switchCamera()
    func toggleTorch()
}

class BottomBarView: UIView {
    
    let capturePhotoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lavanda.cgColor
        button.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let switchCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(switchButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let torchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bolt"), for: .normal)
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.addTarget(self, action: #selector(torchButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var delegate : BottomBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented ")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    @objc func torchButtonPressed() {
        delegate?.toggleTorch()
    }
    
    @objc func captureButtonPressed() {
        delegate?.captureButtonPressed()
    }
    
    @objc func switchButtonPressed() {
        delegate?.switchCamera()
    }
}

extension BottomBarView {
    private func setupView() {
        backgroundColor = .black.withAlphaComponent(0.6)
        translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [torchButton, capturePhotoButton, switchCameraButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 50
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
            stackView.heightAnchor.constraint(equalToConstant: 80),
            
            torchButton.widthAnchor.constraint(equalToConstant: 70),
            torchButton.heightAnchor.constraint(equalToConstant: 70),
            
            capturePhotoButton.widthAnchor.constraint(equalToConstant: 80),
            capturePhotoButton.heightAnchor.constraint(equalToConstant: 80),
            
            switchCameraButton.widthAnchor.constraint(equalToConstant: 70),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}

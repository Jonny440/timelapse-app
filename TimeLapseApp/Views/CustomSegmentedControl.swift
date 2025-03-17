//
//  CustomSegmentedControl.swift
//  TimeLapseApp
//
//  Created by Z1 on 24.02.2025.
//

import Foundation
import UIKit

class CustomSegmentedControl: UIView {
    private var buttons : [UIButton] = []
    private var storageKey = "defaultKey"
    
    var selectedIndex = 0 {
        didSet {
            UserDefaults.standard.set(selectedIndex, forKey: storageKey)
            updateUI()
        }
    }
    
    var options: [(title: String?, symbol: String?)] = [
        (title: "Video", symbol: nil),
        (title: nil, symbol: "photo.fill")
    ] {
        didSet { setupButtons() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    var selectionChanged : ((Int) -> (Void))?
    
    private func setupButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            
            if let symbol = option.symbol {
                let image = UIImage(systemName: symbol)
                button.setImage(image, for: .normal)
                button.tintColor = .white
            } else if let title = option.title {
                button.setTitle(title, for: .normal)
                button.setTitleColor(.white, for: .normal)
            }

            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        updateUI()
    }
    
    private func updateUI() {
        for (index, button) in buttons.enumerated() {
            if options[index].symbol != nil {
                button.tintColor = index == selectedIndex ? .yellow : .white
            } else {
                button.setTitleColor(index == selectedIndex ? .yellow : .white, for: .normal)
            }
        }
        selectionChanged?(selectedIndex)
    }
    
    func setStorageKey(_ key: String) {
        self.storageKey = key
        selectedIndex = UserDefaults.standard.integer(forKey: storageKey)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
    }
}

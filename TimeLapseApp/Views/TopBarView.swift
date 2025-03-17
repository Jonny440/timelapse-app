//
//  TopBarView.swift
//  TimeLapseApp
//
//  Created by Z1 on 24.01.2025.
//

import UIKit

protocol TopBarDelegate {
    func toggleTorch()
}

class TopBarView: UIView {
    
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

}

extension TopBarView {
    
    private func setupView() {
        backgroundColor = .black.withAlphaComponent(0.6)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

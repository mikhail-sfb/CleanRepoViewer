//
//  BaseCardView.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

class BaseCardView: UIView {

    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = Spacing.CornerRadius.m
        layer.borderWidth = 1
        layer.borderColor = UIColor.border.cgColor
    }
}

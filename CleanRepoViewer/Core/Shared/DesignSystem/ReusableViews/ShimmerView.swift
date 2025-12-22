//
//  ShimmerView.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import SnapKit
import UIKit

// Used when list is empty (Custom realisation of existing solution)
final class ShimmerView: UIView {

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)

        let baseColor = UIColor.backgroundSecondary
        let shimmerColor = UIColor.backgroundTertiary

        layer.colors = [
            baseColor.cgColor,
            shimmerColor.cgColor,
            baseColor.cgColor,
        ]

        layer.locations = [0, 0.5, 1]
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = Spacing.CornerRadius.m
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }

    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}

final class ShimmerCell: UITableViewCell {

    static let reuseIdentifier = "ShimmerCell"

    private let shimmerView = ShimmerView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .background
        selectionStyle = .none
        contentView.addSubview(shimmerView)
    }

    private func setupConstraints() {
        shimmerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AdaptiveSpacing.cardSpacing)
            make.left.right.equalToSuperview().inset(
                AdaptiveSpacing.horizontalPadding
            )
            make.bottom.equalToSuperview().offset(-AdaptiveSpacing.cardSpacing)
            make.height.equalTo(100)

            if let maxWidth = AdaptiveSpacing.maxContentWidth {
                make.width.lessThanOrEqualTo(maxWidth)
                make.centerX.equalToSuperview()
            }
        }
    }

    func startShimmering() {
        shimmerView.startAnimating()
    }
}

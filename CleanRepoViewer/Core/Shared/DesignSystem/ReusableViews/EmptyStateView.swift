//
//  EmptyStateView.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import SnapKit
import UIKit

final class EmptyStateView: UIView {

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .titleMedium
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyMedium
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(icon: String, title: String, message: String) {
        super.init(frame: .zero)
        iconLabel.text = icon
        titleLabel.text = title
        messageLabel.text = message
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .background
        addSubview(iconLabel)
        addSubview(titleLabel)
        addSubview(messageLabel)
    }

    private func setupConstraints() {
        iconLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-Spacing.Space.xxxl * 1.25)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconLabel.snp.bottom).offset(Spacing.Space.xl)
            make.left.right.equalToSuperview().inset(Spacing.Space.xxl)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.Space.xs)
            make.left.right.equalToSuperview().inset(Spacing.Space.xxl)
        }
    }
}

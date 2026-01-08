//
//  LoadingView.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import SnapKit
import UIKit

final class LoadingView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyMedium
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(message: String = "Loading...") {
        super.init(frame: .zero)
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
        addSubview(activityIndicator)
        addSubview(messageLabel)
    }

    private func setupConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(activityIndicator.snp.bottom).offset(
                Spacing.Space.m
            )
            make.left.right.equalToSuperview().inset(Spacing.Space.xxl)
        }
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

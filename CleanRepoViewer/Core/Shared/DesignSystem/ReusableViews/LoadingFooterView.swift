//
//  LoadingFooterView.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import SnapKit
import UIKit

final class LoadingFooterCell: UITableViewCell {

    static let reuseIdentifier = "LoadingFooterCell"

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .primary
        indicator.hidesWhenStopped = false
        return indicator
    }()

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
        contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func setupConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(Spacing.Space.m)
        }
    }
}

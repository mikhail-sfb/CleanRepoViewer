//
//  RepositoryCell.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import SnapKit
import UIKit

final class RepositoryCell: UITableViewCell {

    static let reuseIdentifier = "RepositoryCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Spacing.CornerRadius.m
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.border.cgColor
        return view
    }()

    private let iconView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary.withAlphaComponent(0.15)
        view.layer.cornerRadius = Spacing.CornerRadius.s
        return view
    }()

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "🌞"
        label.font = .titleLarge
        label.textAlignment = .center
        return label
    }()

    private let nameLabel = TitleLabel(numberOfLines: 2)
    private let descriptionLabel = SubtitleLabel(numberOfLines: 3)

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .textTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func setupView() {
        backgroundColor = .background
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        iconView.addSubview(iconLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(arrowImageView)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AdaptiveSpacing.cardSpacing)
            make.left.right.equalToSuperview().inset(
                AdaptiveSpacing.horizontalPadding
            )
            make.bottom.equalToSuperview().offset(-AdaptiveSpacing.cardSpacing)

            if let maxWidth = AdaptiveSpacing.maxContentWidth {
                make.width.lessThanOrEqualTo(maxWidth)
                make.centerX.equalToSuperview()
            }
        }

        iconView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(Spacing.Space.m)
            make.width.height.equalTo(Spacing.IconSize.xl)
        }

        iconLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.Space.m)
            make.left.equalTo(iconView.snp.right).offset(Spacing.Space.s)
            make.right.equalTo(arrowImageView.snp.left).offset(-Spacing.Space.s)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.Space.xxs)
            make.left.equalTo(iconView.snp.right).offset(Spacing.Space.s)
            make.right.equalTo(arrowImageView.snp.left).offset(-Spacing.Space.s)
            make.bottom.lessThanOrEqualToSuperview().offset(-Spacing.Space.m)
        }

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-Spacing.Space.m)
            make.width.height.equalTo(Spacing.IconSize.s)
        }
    }

    func configure(with repository: Repository) {
        nameLabel.text = repository.name
        descriptionLabel.text =
            repository.description ?? "No description available"
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        UIView.animate(withDuration: 0.2) {
            self.containerView.transform =
                highlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}

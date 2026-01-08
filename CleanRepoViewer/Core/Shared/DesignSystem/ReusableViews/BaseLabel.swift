//
//  BaseLabel.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

// Overcomplicated for this project, but the effort involved is not that big
class BaseLabel: UILabel {

    init(
        font: UIFont,
        textColor: UIColor,
        numberOfLines: Int = 1,
        textAlignment: NSTextAlignment = .left
    ) {
        super.init(frame: .zero)
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class TitleLabel: BaseLabel {
    init(numberOfLines: Int = 1) {
        super.init(
            font: .bodyLarge,
            textColor: .textPrimary,
            numberOfLines: numberOfLines
        )
    }
}

final class SubtitleLabel: BaseLabel {
    init(numberOfLines: Int = 2) {
        super.init(
            font: .bodySmall,
            textColor: .textSecondary,
            numberOfLines: numberOfLines
        )
    }
}

final class CaptionLabel: BaseLabel {
    init(numberOfLines: Int = 1) {
        super.init(
            font: .caption,
            textColor: .textTertiary,
            numberOfLines: numberOfLines
        )
    }
}

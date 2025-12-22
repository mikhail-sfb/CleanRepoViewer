//
//  Typography.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

// Laba reuse (mostly)
extension UIFont {

    public static let titleLarge: UIFont = .systemFont(
        ofSize: 24,
        weight: .bold
    )
    public static let titleMedium: UIFont = .systemFont(
        ofSize: 20,
        weight: .semibold
    )
    public static let titleSmall: UIFont = .systemFont(
        ofSize: 18,
        weight: .semibold
    )

    public static let bodyLarge: UIFont = .systemFont(
        ofSize: 16,
        weight: .semibold
    )
    public static let bodyMedium: UIFont = .systemFont(
        ofSize: 16,
        weight: .regular
    )
    public static let bodySmall: UIFont = .systemFont(
        ofSize: 14,
        weight: .regular
    )

    public static let caption: UIFont = .systemFont(
        ofSize: 12,
        weight: .regular
    )
}

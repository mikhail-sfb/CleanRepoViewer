//
//  ColorScheme.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

// Reuse of Musica Color pallete (my MTK side project)
extension UIColor {

    public static let primary: UIColor = .init(hexString: "#08D496")
    public static let primaryDark: UIColor = .init(hexString: "#06B57D")
    public static let primaryLight: UIColor = .init(hexString: "#0AEAA8")

    public static let background: UIColor = .init(hexString: "#0F0F0F")
    public static let backgroundSecondary: UIColor = .init(hexString: "#1A1A1A")
    public static let backgroundTertiary: UIColor = .init(hexString: "#242424")

    public static let textPrimary: UIColor = .init(hexString: "#FFFFFF")
    public static let textSecondary: UIColor = .init(hexString: "#B0B0B0")
    public static let textTertiary: UIColor = .init(hexString: "#6B6B6B")

    public static let border: UIColor = .init(hexString: "#2A2A2A")
    public static let borderLight: UIColor = .init(hexString: "#3A3A3A")

    public static let success: UIColor = .init(hexString: "#08D496")
    public static let error: UIColor = .init(hexString: "#FF4D4D")
    public static let warning: UIColor = .init(hexString: "#FFA726")

    public convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6:
            (alpha, red, green, blue) = (
                255, int >> 16, int >> 8 & 0xFF, int & 0xFF
            )
        case 8:
            (alpha, red, green, blue) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
}

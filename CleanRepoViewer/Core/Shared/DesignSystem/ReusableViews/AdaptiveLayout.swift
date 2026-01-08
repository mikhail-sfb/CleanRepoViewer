//
//  AdaptiveLayout.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

enum DeviceType {
    case phone
    case pad

    static var current: DeviceType {
        return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
    }
}

enum AdaptiveSpacing {
    static var horizontalPadding: CGFloat {
        switch DeviceType.current {
        case .phone:
            return Spacing.Space.m
        case .pad:
            return Spacing.Space.xxl
        }
    }

    static var cardSpacing: CGFloat {
        switch DeviceType.current {
        case .phone:
            return Spacing.Space.xs
        case .pad:
            return Spacing.Space.m
        }
    }

    static var maxContentWidth: CGFloat? {
        switch DeviceType.current {
        case .phone:
            return nil
        case .pad:
            return 800
        }
    }
}

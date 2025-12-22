//
//  Spacing.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

// Laba reuse (mostly)
public enum Spacing {

    private static let unit: CGFloat = 4

    public enum Space {
        public static var xxs: CGFloat { unit * 1 }
        public static var xs: CGFloat { unit * 2 }
        public static var s: CGFloat { unit * 3 }
        public static var m: CGFloat { unit * 4 }
        public static var l: CGFloat { unit * 5 }
        public static var xl: CGFloat { unit * 6 }
        public static var xxl: CGFloat { unit * 8 }
        public static var xxxl: CGFloat { unit * 12 }
    }

    public enum Padding {
        public static var xxs: UIEdgeInsets {
            .init(
                top: Space.xxs,
                left: Space.xxs,
                bottom: Space.xxs,
                right: Space.xxs
            )
        }
        public static var xs: UIEdgeInsets {
            .init(
                top: Space.xs,
                left: Space.xs,
                bottom: Space.xs,
                right: Space.xs
            )
        }
        public static var s: UIEdgeInsets {
            .init(top: Space.s, left: Space.s, bottom: Space.s, right: Space.s)
        }
        public static var m: UIEdgeInsets {
            .init(top: Space.m, left: Space.m, bottom: Space.m, right: Space.m)
        }
        public static var l: UIEdgeInsets {
            .init(top: Space.l, left: Space.l, bottom: Space.l, right: Space.l)
        }
        public static var xl: UIEdgeInsets {
            .init(
                top: Space.xl,
                left: Space.xl,
                bottom: Space.xl,
                right: Space.xl
            )
        }
        public static var xxl: UIEdgeInsets {
            .init(
                top: Space.xxl,
                left: Space.xxl,
                bottom: Space.xxl,
                right: Space.xxl
            )
        }
    }

    public enum CornerRadius {
        public static var s: CGFloat { unit * 2 }
        public static var m: CGFloat { unit * 3 }
        public static var l: CGFloat { unit * 4 }
        public static var xl: CGFloat { unit * 6 }
    }

    public enum IconSize {
        public static var s: CGFloat { unit * 4 }
        public static var m: CGFloat { unit * 6 }
        public static var l: CGFloat { unit * 8 }
        public static var xl: CGFloat { unit * 12 }
    }
}

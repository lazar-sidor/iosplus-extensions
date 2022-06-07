//
//  UIFont+Extension.swift
//  Nanit BDay
//
//  Created by Lazar Sidor on 24.05.2022.
//

import UIKit

extension UIFont {
    public static func listAvailableFonts() {
        for family: String in UIFont.familyNames.sorted() {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }

    @available(iOS 11.0, *)
    public func dynamicallyTyped(withStyle style: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self)
    }

    @available(iOS 11.0, *)
    public static func customFont(withStyle style: UIFont.TextStyle, name: String, size fontSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: name, size: fontSize)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        }
        return customFont.dynamicallyTyped(withStyle: style)
    }

    public static func customFont(size: CGFloat, name: String, weight: UIFont.Weight) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }

        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}

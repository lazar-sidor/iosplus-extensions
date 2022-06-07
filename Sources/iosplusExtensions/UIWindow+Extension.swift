//
//  UIWindow+Extension.swift
//
//  Created by Lazar Sidor on 03.06.2022.
//

import UIKit

extension UIWindow {
    public static func keyWindow() -> UIWindow? {
        if #available(iOS 15, *) {
            let scene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
            let keyWindow = scene?.keyWindow
            return keyWindow
        } else if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

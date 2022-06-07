//
//  UITextField+Extension.swift
//
//  Created by Lazar Sidor on 25.02.2022.
//

import Foundation
import UIKit

extension UITextField {
    public func addDoneButtonOnKeyboard(doneButtonTitle: String? = "Done", target: AnyObject, doneSelector: Selector) {
        let doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: doneButtonTitle, style: .done, target: target, action: doneSelector)

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
}

//
//  UITextField+YearMonthPicker.swift
//
//  Created by Lazar Sidor on 22.02.2022.
//

import UIKit

public class DatePickerConfiguration {
    public var mode: UIDatePicker.Mode = .date
    public var locale: Locale = .current
    public var cancelButtonTitle: String? = "Cancel"
    public var doneButtonTitle: String? = "Done"
}

public extension UITextField {
    @objc func tapCancel() {
        resignFirstResponder()
    }

    func setInputViewDatePicker(target: Any, didChangeSelector: Selector, doneSelector: Selector, minDate: Date?, maxDate: Date?, currentValue: Date? = nil, configuration: DatePickerConfiguration) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = configuration.mode
        datePicker.calendar = configuration.locale.calendar
        datePicker.timeZone = configuration.locale.calendar.timeZone
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.addTarget(target, action: didChangeSelector, for: .valueChanged)

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        if let value = currentValue {
            datePicker.date = value
        }

        self.inputView = datePicker

        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: configuration.cancelButtonTitle, style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: configuration.doneButtonTitle, style: .plain, target: target, action: doneSelector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}

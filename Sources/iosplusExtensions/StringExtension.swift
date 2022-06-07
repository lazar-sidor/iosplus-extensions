//
//  StringExtension.swift
//

import Foundation


extension String {
    /**
    Convert argb string to rgba string.
    */
    public var argb2rgba: String? {
        guard self.hasPrefix("#") else {
            return nil
        }
        
        let hexString = String(self[self.index(self.startIndex, offsetBy: 1)...])
        switch hexString.count {
        case 4:
            return "#\(String(hexString[self.index(self.startIndex, offsetBy: 1)...]))\(String(hexString[..<self.index(self.startIndex, offsetBy: 1)]))"
        case 8:
            return "#\(String(hexString[self.index(self.startIndex, offsetBy: 2)...]))\(String(hexString[..<self.index(self.startIndex, offsetBy: 2)]))"
        default:
            return nil
        }
    }
}

public extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

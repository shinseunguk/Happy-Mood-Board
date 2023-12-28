//
//  UIColor+BeeHappy.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/08.
//

import UIKit

public extension UIColor {
    
    convenience init?(hexString: String, transparency: CGFloat = 1) {
        var string = ""
        let lowercaseHexString = hexString.lowercased()
        if lowercaseHexString.hasPrefix("0x") {
            string = lowercaseHexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }
        
        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        
        guard let hexValue = Int(string, radix: 16) else { return nil }
        
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
}

public extension UIColor {
    
    // MARK: Primary Color
    
    static let primary100: UIColor? = .init(hexString: "#FCF6E4")
    static let primary200: UIColor? = .init(hexString: "#FCE9BF")
    static let primary300: UIColor? = .init(hexString: "#FDDF9F")
    static let primary400: UIColor? = .init(hexString: "#FED47C")
    static let primary500: UIColor? = .init(hexString: "#FFCE53")
    static let primary600: UIColor? = .init(hexString: "#F4C362")
    static let primary700: UIColor? = .init(hexString: "#EABF6E")
    static let primary800: UIColor? = .init(hexString: "#DFBC79")
    static let primary900: UIColor? = .init(hexString: "#D9BF8E")
    
    // MARK: Gray Scale
    
    static let gray100: UIColor? = .init(hexString: "#F9F8F5")
    static let gray200: UIColor? = .init(hexString: "#E8E6E1")
    static let gray300: UIColor? = .init(hexString: "#D3D0CA")
    static let gray400: UIColor? = .init(hexString: "#BEBCB9")
    static let gray500: UIColor? = .init(hexString: "#8B8B8B")
    static let gray600: UIColor? = .init(hexString: "#6F6F6F")
    static let gray700: UIColor? = .init(hexString: "#555555")
    static let gray800: UIColor? = .init(hexString: "#3D3D3D")
    static let gray900: UIColor? = .init(hexString: "#242424")
    
    // MARK: Yellow Color
    static let yellow100: UIColor? = .init(hexString: "#FAE100")
    
    // MARK: Accent Color
    
    static let accent100: UIColor? = .init(hexString: "#FF5D5D")
    static let accent200: UIColor? = .init(hexString: "#A9CEEF")
    static let accent300: UIColor? = .init(hexString: "#FFC895")
    static let accent400: UIColor? = .init(hexString: "#BBDE98")
    static let accent500: UIColor? = .init(hexString: "#E9CAE6")
    
}

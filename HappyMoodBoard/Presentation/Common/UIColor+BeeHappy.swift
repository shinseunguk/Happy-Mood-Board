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
    
    static let Main100: UIColor? = .init(hexString: "#9DC4FF")
    static let Main200: UIColor? = .init(hexString: "#7BB0FF")
    static let Main300: UIColor? = .init(hexString: "#599BFF")
    static let Main400: UIColor? = .init(hexString: "#428DFF")
    static let Main500: UIColor? = .init(hexString: "#247BFF")
    static let Main600: UIColor? = .init(hexString: "#0065FF")
    static let Main700: UIColor? = .init(hexString: "#0057DB")
    static let Main800: UIColor? = .init(hexString: "#0048B7")
    static let Main900: UIColor? = .init(hexString: "#003F9F")
    static let Main950: UIColor? = .init(hexString: "#003079")
    
    static let TitleFont100: UIColor? = .init(hexString: "#525252")
    static let TitleFont200: UIColor? = .init(hexString: "#454545")
    static let TitleFont300: UIColor? = .init(hexString: "#383838")
    static let TitleFont400: UIColor? = .init(hexString: "#2B2B2B")
    static let TitleFont500: UIColor? = .init(hexString: "#1F1F1F")
    static let TitleFont600: UIColor? = .init(hexString: "#111111")
    static let TitleFont700: UIColor? = .init(hexString: "#000000")
    
    static let BodyFont1: UIColor? = .init(hexString: "#616161")
    static let BodyFont2: UIColor? = .init(hexString: "#9A9A9A")
    static let BodyFont3: UIColor? = .init(hexString: "#B5B5B5")
    
    static let Line1: UIColor? = .init(hexString: "#AEB4A4")
    static let Line2: UIColor? = .init(hexString: "#BFC3B8")
    static let Line3: UIColor? = .init(hexString: "#DADDD6")
    
    static let BG1: UIColor? = .init(hexString: "#EEF1EA")
    static let BG2: UIColor? = .init(hexString: "#F4F6F1")
    static let BG3: UIColor? = .init(hexString: "#F8F9F5")
    static let BG4: UIColor? = .init(hexString: "#FBFDFA")
    static let Disabled: UIColor? = .init(hexString: "#DEE3D7")
 
    static let background: UIColor? = .init(hexString: "#FCF6E4")
    
}

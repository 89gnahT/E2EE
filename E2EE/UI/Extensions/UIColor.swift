//
//  UIColor.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

extension UIColor {
    class func n1MidGreyColor() -> UIColor {
        return UIColor(red: 144.0 / 255.0, green: 164.0 / 255.0, blue: 174.0 / 255.0, alpha: 1)
    }
    
    class func n1DarkestGreyColor() -> UIColor {
        return UIColor(red: 38.0 / 255.0, green: 50.0 / 255.0, blue: 56.0 / 255.0, alpha: 1)
    }
    
    class func n1DarkGreyColor() -> UIColor {
        return UIColor(red: 96.0 / 255.0, green: 125.0 / 255.0, blue: 139.0 / 255.0, alpha: 1)
    }
    
    class func n1WhiteColor() -> UIColor {
        return UIColor(white: 255.0 / 255.0, alpha: 1)
    }
    
    class func n1BrandRedColor() -> UIColor {
        return UIColor(red: 255.0 / 255.0, green: 38.0 / 255.0, blue: 66.0 / 255.0, alpha: 1)
    }
    
    class func n1ActionBlueColor() -> UIColor {
        return UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1)
    }
    
    class func n1OverlayBorderColor() -> UIColor {
        return UIColor(red: 38.0 / 255.0, green: 49.0 / 255.0, blue: 56.0 / 255.0, alpha: 0.1)
    }
    
    class func n1AlmostWhiteColor() -> UIColor {
        return UIColor(red: 251.0 / 255.0, green: 252.0 / 255.0, blue: 253.0 / 255.0, alpha: 1)
    }
    
    class func n1DarkerGreyColor() -> UIColor {
        return UIColor(red: 69.0 / 255.0, green: 90.0 / 255.0, blue: 100.0 / 255.0, alpha: 1)
    }
    
    class func n1LightGreyColor() -> UIColor {
        return UIColor(red: 207.0 / 255.0, green: 216.0 / 255.0, blue: 220.0 / 255.0, alpha: 1)
    }
    
    class func n1LighterGreyColor() -> UIColor {
        return UIColor(red: 233.0 / 255.0, green: 239.0 / 255.0, blue: 242.0 / 255.0, alpha: 1)
    }
    
    class func n1PaleGreyColor() -> UIColor {
        return UIColor(red: 243.0 / 255.0, green: 247.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
    }
    
    class func n1Black50Color() -> UIColor {
        return UIColor(white: 0.0, alpha: 0.5)
    }
    
    class func colorFromRGB(_ rgbHexValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbHexValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbHexValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbHexValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    /** returns a random color */
    class func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func toHexString() -> String{
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
        //return "" + r + "" + g + "" + b + "" + a
    }
    
    convenience init(r: UInt8, g: UInt8 , b: UInt8 , a: UInt8 = 255) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
}

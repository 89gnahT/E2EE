//
//  Common.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

let MINUTE = TimeInterval(60)
let HOURS = TimeInterval(3600)
let DAY = TimeInterval(86400)
let WEEK = TimeInterval(604800)

var thePresentTime : TimeInterval{
    return Date.timeIntervalSinceReferenceDate
}

func attributedString(_ string : String,
                     fontSize : CGFloat,
                     isHighLight : Bool,
                     highLightColor : UIColor,
                     normalColor : UIColor) -> NSAttributedString{
    
    var attributedText : NSAttributedString
    
    if isHighLight{
        attributedText = attributedString(string, fontSize: fontSize, isBold: true, foregroundColor: highLightColor)
    }else{
        attributedText = attributedString(string, fontSize: fontSize, isBold: false, foregroundColor: normalColor)
    }
    return attributedText
}

func attributedString(_ string : String,
                     fontSize : CGFloat,
                     isBold : Bool,
                     foregroundColor : UIColor) -> NSAttributedString{
    var font : UIFont
    if isBold{
        font = UIFont.boldDefaultFont(ofSize: fontSize)
    }else{
        font = UIFont.defaultFont(ofSize: fontSize)
    }
    
    return NSAttributedString(string: string,
                              attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : foregroundColor])
}

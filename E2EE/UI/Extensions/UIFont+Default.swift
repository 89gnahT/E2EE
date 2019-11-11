//
//  UIFont.swift
//  LearnTextureKit
//
//  Created by Truong Nguyen on 11/6/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

extension UIFont {
    class func defaultFont(ofSize fontSize : CGFloat) -> UIFont{
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    class func boldDefaultFont(ofSize fontSize : CGFloat) -> UIFont{
        return UIFont.boldSystemFont(ofSize: fontSize)
    }
}

//
//  ContentNode.swift
//  E2EE
//
//  Created by CPU12015 on 12/6/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContentNode: ASDisplayNode, UIGestureRecognizerDelegate {
    var justifyContent : ASStackLayoutJustifyContent = .start
    var tapAction: Selector!
    var longPressAction: Selector!
    
    init(tapAction: Selector, longPressAction: Selector) {
        super.init()
        
        self.tapAction = tapAction
        self.longPressAction = longPressAction
        setup()
    }
    
    public func setup(){
        
    }
    
    public func updateUI(){
        
    }
}

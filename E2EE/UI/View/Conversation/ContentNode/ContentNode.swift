//
//  ContentNode.swift
//  E2EE
//
//  Created by CPU12015 on 12/6/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContentNode: ASControlNode, UIGestureRecognizerDelegate {
    var justifyContent : ASStackLayoutJustifyContent = .start
    var tapAction: Selector!
    var longPressAction: Selector!
    
    init(tapAction: Selector? = nil) {
        super.init()
        
        self.tapAction = tapAction
        
        self.automaticallyManagesSubnodes = true
        setup()
    }
    
    public func setup(){
        
    }
    
    public func updateUI(){
        
    }
}

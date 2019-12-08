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
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.isUserInteractionEnabled = true
 
        setup()
    }
    
    public func setup(){
        
    }
    
    public func updateUI(_ isHightlight: Bool = false){
        
    }
}

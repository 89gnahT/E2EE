//
//  ContentNode.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

open class ContentNode: ASControlNode {
    open var isIncomingMessage = true
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }
    
}


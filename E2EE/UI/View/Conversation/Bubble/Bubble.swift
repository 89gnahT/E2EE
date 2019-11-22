//
//  Bubble.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit


open class Bubble : ASImageNode{
    
    init(with image : UIImage? = nil) {
        super.init()
        self.image = image
    }
}


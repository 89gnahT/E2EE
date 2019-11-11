//
//  CGSize.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

extension CGSize {
    public init(squareEdge : CGFloat) {
        self.init()
        
        width = squareEdge
        height = width
    }
}

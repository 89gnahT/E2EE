//
//  CGRect+OriginInfinity.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/12/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

extension CGRect{
    func originInfinity() -> Bool{
        return origin.x == .infinity || origin.y == .infinity
    }
}

//
//  BubbleConfigurationProtocol.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public protocol BubbleConfigurationProtocol {
    var isMasked : Bool { get set }

    func getIncomingColor() -> UIColor

    func getOutgoingColor() -> UIColor
    
    func getFirstBubble() -> Bubble
    
    func getDefaultBubble() -> Bubble
    
    func getLastBubble() -> Bubble
}

//
//  StandardBubbleConfiguration.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class StandardBubbleConfiguration: BubbleConfigurationProtocol {
    public var isMasked: Bool = false
    
    public func getIncomingColor() -> UIColor {
        return UIColor.blue
    }
    
    public func getOutgoingColor() -> UIColor {
        return UIColor.n1ActionBlueColor()
    }
    
    public func getFirstBubble() -> Bubble {
        return getDefaultBubble()
    }
    
    public func getDefaultBubble() -> Bubble {
        let newBubble = DefaultBubble()
        newBubble.hasLayerMask = isMasked
        return newBubble
    }
    
    public func getLastBubble() -> Bubble {
        return getDefaultBubble()
    }
    
    init() {
        
    }
}

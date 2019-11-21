//
//  Bubble.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

//MARK: Bubble class
/**
 'Abstract' Bubble class. Subclass for creating a custom bubble
 */
open class Bubble {
    
    // MARK: Public Parameters
    open var bubbleColor : UIColor = UIColor.n1PaleGreyColor()
    
    /** When this is set, the layer mask will mask the ContentNode.*/
    open var hasLayerMask = false
    
    /**
     A layer for the bubble. Make sure this property is first accessed on the main thread.
     */
    open lazy var layer: CAShapeLayer = CAShapeLayer()
    /**
     A layer that holds a mask which is the same shape as the bubble. This can be used to mask anything in the ContentNode to the same shape as the bubble.
     */
    open lazy var maskLayer: CAShapeLayer = CAShapeLayer()
        
    /** Bounds of the bubble*/
    open var calculatedBounds = CGRect.zero
    
    // MARK: Initialisers
    public init() {}
    
    // MARK: Class methods
    /**
     Sizes the layer accordingly. This function should **always** be thread safe.
     -parameter bounds: The bounds of the content
     */
    open func sizeToBounds(_ bounds: CGRect) {
        self.calculatedBounds = bounds
    }
    
    /**
     This function should be called on the  main thread. It makes creates the layer with the calculated values from *sizeToBounds*
     */
    open func createLayer() {
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.maskLayer.shouldRasterize = true
        self.maskLayer.rasterizationScale = UIScreen.main.scale
    }
    
}


//
//  DefaultBubble.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

open class DefaultBubble: Bubble {
    
    //MARK: Public Variables
    
    /** Radius of the corners for the bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    open var radius : CGFloat = 16
    /** Should be less or equal to the *radius* property. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    open var borderWidth : CGFloat = 0 //TODO:
    /** The color of the border around the bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    open var bubbleBorderColor : UIColor = UIColor.clear
    /** Path used to cutout the bubble*/
    open fileprivate(set) var path: CGMutablePath = CGMutablePath()
    
    // MARK: Initialisers
    
    /**
     Initialiser class.
     */
    public override init() {
        super.init()
    }
    
    // MARK: Class methods
    
    /**
     Overriding sizeToBounds from super class
     -parameter bounds: The bounds of the content
     */
    open override func sizeToBounds(_ bounds: CGRect) {
        super.sizeToBounds(bounds)
        
        var rect = CGRect.zero
        var radius2: CGFloat = 0
        
        if bounds.width < 2*radius || bounds.height < 2*radius { //if the rect calculation yeilds a negative result
            let newRadiusW = bounds.width/2
            let newRadiusH = bounds.height/2
            
            let newRadius = newRadiusW>newRadiusH ? newRadiusH : newRadiusW
            
            rect = CGRect(x: newRadius, y: newRadius, width: bounds.width - 2*newRadius, height: bounds.height - 2*newRadius)
            radius2 = newRadius - borderWidth / 2
        } else {
            rect = CGRect(x: radius, y: radius, width: bounds.width - 2*radius, height: bounds.height - 2*radius)
            radius2 = radius - borderWidth / 2
        }
        
        path = CGMutablePath()
        
        path.addArc(center: CGPoint(x: rect.maxX, y: rect.minY), radius: radius2, startAngle: CGFloat(-Double.pi/2), endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX + radius2, y: rect.maxY + radius2))
        path.addArc(center: CGPoint(x: rect.minX, y: rect.maxY), radius: radius2, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi), clockwise: false)
        path.addArc(center: CGPoint(x: rect.minX, y: rect.minY), radius: radius2, startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi/2), clockwise: false)
        
        path.closeSubpath()
    }
    
    /**
     Overriding createLayer from super class
     */
    open override func createLayer() {
        super.createLayer()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.layer.path = path
        self.layer.fillColor = self.bubbleColor.cgColor
        self.layer.strokeColor = self.bubbleBorderColor.cgColor
        self.layer.lineWidth = self.borderWidth
        self.layer.position = CGPoint.zero
        
        self.maskLayer.fillColor = UIColor.black.cgColor
        self.maskLayer.path = path
        self.maskLayer.position = CGPoint.zero
        CATransaction.commit()
        
    }
}

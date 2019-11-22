//
//  StandardBubbleConfiguration.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class StandardBubbleConfiguration : BubbleConfigurationProtocol{
    public func getIncomingColor() -> UIColor {
        return .systemBlue
    }
    
    public func getOutgoingColor() -> UIColor {
        return .systemBlue
    }
    
    public func getFirstIncomingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_in_first"))
     
    }
    
    public func getFirstOutgoingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_out_first"))
        
    }
    
    public func getMidIncomingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_in_mid"))
        
    }
    
    public func getMidOutgoingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_out_mid"))
        
    }
    
    public func getLastIncomingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_in_last"))
        
    }
    
    public func getLastOutgoingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_out_last"))
       
    }
    
    public func getDefaultInComingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_default"))
       
    }
    
    public func getDefaultOutgoingBubble() -> UIImage? {
        return resizableImage(UIImage(named: "bubble_default"))
    
    }
    
    
    
}

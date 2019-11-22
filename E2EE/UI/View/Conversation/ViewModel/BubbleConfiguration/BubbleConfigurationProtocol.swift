//
//  BubbleConfigurationProtocol.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public protocol BubbleConfigurationProtocol {
    
    func getIncomingColor() -> UIColor
    
    func getOutgoingColor() -> UIColor
    
    func getFirstIncomingBubble() -> UIImage?
    
    func getFirstOutgoingBubble() -> UIImage?
    
    func getMidIncomingBubble() -> UIImage?
    
    func getMidOutgoingBubble() -> UIImage?
    
    func getLastIncomingBubble() -> UIImage?
    
    func getLastOutgoingBubble() -> UIImage?
    
    func getDefaultInComingBubble() -> UIImage?
 
    func getDefaultOutgoingBubble() -> UIImage?
}

extension BubbleConfigurationProtocol{
    func resizableImage(_ i : UIImage?) -> UIImage?{
        guard let bubbleImage = i?.maskWithColor(color: getIncomingColor()) else {
            return nil
        }
        
        
        let center = CGPoint(x: bubbleImage.size.width / 2.0, y: bubbleImage.size.height / 2.0);
        let capInsets = UIEdgeInsets(top: center.y - 1, left: center.x - 1, bottom: center.y - 1, right: center.x - 1);
        return bubbleImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}

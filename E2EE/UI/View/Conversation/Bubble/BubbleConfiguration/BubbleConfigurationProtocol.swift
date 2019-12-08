//
//  BubbleConfigurationProtocol.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import PINCache
public enum MessageCellPosition {
    case first
    case middle
    case last
    case none
}

public protocol BubbleConfigurationProtocol {
    
    func getIncomingColor(isHighlight highlight: Bool) -> UIColor
    
    func getOutcomingColor(isHighlight highlight: Bool) -> UIColor
    
    func getBubbleImage(isIncoming incoming : Bool, position pos : MessageCellPosition, isHighlight highlight: Bool) -> UIImage?
    
}

extension BubbleConfigurationProtocol{
    public func getColor(isIncoming incoming: Bool, isHighlight highlight: Bool) -> UIColor {
        return incoming ? getIncomingColor(isHighlight: highlight) : getOutcomingColor(isHighlight: highlight)
       }
    
    func resizableImage(_ i : UIImage?, color : UIColor, imageName: String) -> UIImage?{
                
        let object = PINCache.shared.object(forKey: imageName)
        var resultImage = object != nil ? (object as? UIImage) : nil
        
        if resultImage == nil{
            guard let bubbleImage = i?.maskWithColor(color: color) else {
                return nil
            }
            let center = CGPoint(x: bubbleImage.size.width / 2.0, y: bubbleImage.size.height / 2.0);
            let capInsets = UIEdgeInsets(top: center.y - 1,
                                         left: center.x - 1,
                                         bottom: center.y - 1,
                                         right: center.x - 1);
            resultImage = bubbleImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            
            if resultImage != nil{
                PINCache.shared.setObject(resultImage, forKey: imageName)
            }
        }
        return resultImage
    }
}

//
//  BubbleConfigurationProtocol.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public enum MessageCellPosition {
    case first
    case middle
    case last
    case none
}

public protocol BubbleConfigurationProtocol {
    
    func getColor(isIncoming incoming : Bool) -> UIColor
    
    func getBubbleImage(isIncoming incoming : Bool, position pos : MessageCellPosition) -> UIImage?
    
}

extension BubbleConfigurationProtocol{
    func resizableImage(_ i : UIImage?, color : UIColor) -> UIImage?{
        guard let bubbleImage = i?.maskWithColor(color: color) else {
            return nil
        }
        
        let center = CGPoint(x: bubbleImage.size.width / 2.0, y: bubbleImage.size.height / 2.0);
        let capInsets = UIEdgeInsets(top: center.y - 1, left: center.x - 1, bottom: center.y - 1, right: center.x - 1);
        return bubbleImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}

//
//  StandardBubbleConfiguration.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class StandardBubbleConfiguration : BubbleConfigurationProtocol{
            
    static let shared = StandardBubbleConfiguration()
    
    private init() {
        
    }
       
    public func getIncomingColor(isHighlight highlight: Bool) -> UIColor {
        var c: UIColor
        if highlight{
            c = UIColor(r: 192, g: 192, b: 192)            
        }else{
            c = UIColor(r: 240, g: 240, b: 240)
        }
        return c
    }
    
    public func getOutcomingColor(isHighlight highlight: Bool) -> UIColor {
        var c: UIColor
        if highlight{
            c = UIColor(r: 16, g: 108, b: 201)
        }else{
            c = UIColor(r: 23, g: 135, b: 251)
        }
        return c
    }
    
    public func getBubbleImage(isIncoming incoming: Bool, position pos: MessageCellPosition, isHighlight highlight: Bool) -> UIImage? {
        var image : UIImage?
        var imageName: String
        let color = getColor(isIncoming: incoming, isHighlight: highlight)
        
        switch pos {
        case .first:
            imageName = incoming ? "bubble_in_first" : "bubble_out_first"
        case .middle:
            imageName = incoming ? "bubble_in_mid" : "bubble_out_mid"
        case .last:
            imageName = incoming ? "bubble_in_last" : "bubble_out_last"
        case .none:
            imageName = incoming ? "bubble_default" : "bubble_default"
        }
        
        image = UIImage(named: imageName)
        imageName += color.toHexString()
        
        return resizableImage(image, color: color, imageName: imageName)
    }
}

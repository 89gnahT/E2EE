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
    
    public func getColor(isIncoming incoming: Bool) -> UIColor {
        let c = CGFloat(240) / 255
        return incoming ? UIColor(red: c, green: c, blue: c, alpha: 1) : UIColor.systemBlue;
        //return  UIColor.systemBlue;
    }
    
    public func getBubbleImage(isIncoming incoming: Bool, position pos: MessageCellPosition) -> UIImage? {
        var image : UIImage?
        var imageName: String
        let color = getColor(isIncoming: incoming)
        
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

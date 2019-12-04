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
        switch pos {
        case .first:
            image = incoming ? UIImage(named: "bubble_in_first") : UIImage(named: "bubble_out_first")
        case .middle:
            image = incoming ? UIImage(named: "bubble_in_mid") : UIImage(named: "bubble_out_mid")
        case .last:
            image = incoming ? UIImage(named: "bubble_in_last") : UIImage(named: "bubble_out_last")
        case .none:
            image = incoming ? UIImage(named: "bubble_default") : UIImage(named: "bubble_default")
        }
                
        return resizableImage(image, color: getColor(isIncoming: incoming))
    }
}

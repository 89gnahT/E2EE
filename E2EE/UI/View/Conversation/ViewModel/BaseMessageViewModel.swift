//
//  BaseMessageViewModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class BaseMessageViewModel: NSObject {
    
    let timePeriod = TimeInterval(10 * MINUTE)
    
    public func messageTime() -> TimeInterval{
        assert(false, "messageTime should be override in subClass")
        return 0
    }
    
    public func updateData(_ completion : (() -> Void)?){
        
    }
    
    public func isBlockMessageWith(_ other: BaseMessageViewModel?) -> Bool{
        return other != nil && fabs(messageTime() - other!.messageTime()) <= timePeriod
    }
}

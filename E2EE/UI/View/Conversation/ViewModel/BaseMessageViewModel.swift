//
//  BaseMessageViewModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class BaseMessageViewModel: NSObject {
    public func updateData(_ completion : (() -> Void)?){
        
    }
    
    public func isGroupWith(_ other: BaseMessageViewModel) -> Bool{
        return false
    }
    
    public func isBlockMessageWith(_ other: BaseMessageViewModel?) -> Bool{
        return false
    }
}

//
//  MessageTitleViewModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class MessageTitleViewModel: BaseMessageViewModel {
    
    // Maximum time between 2 consecutive messages in a block message
    private(set) var time: TimeInterval
    
    // Number of messages in this time period, this number can be reset to 0
    private(set) var count: Int
    
    private(set) var fristTime: TimeInterval
   
    public var title: NSAttributedString?
    
    init(messageTime: TimeInterval = 0) {
        time = messageTime
        fristTime = time
        count = 1
        
        super.init()
    }
    
    public func resetCount(){
        count = 0
    }
    
    public func updateTime(newTime: TimeInterval){
        time = newTime
        count += 1
    }
    
    public override func messageTime() -> TimeInterval{
        return time
    }
    
    public override func updateData(_ completion : (() -> Void)?){
        title = attributedString(getTimeWithFormath(time: time, format: "hh:mm dd/MM/yyyy"), fontSize: 14, isBold: false, foregroundColor: .darkGray)
    }
}

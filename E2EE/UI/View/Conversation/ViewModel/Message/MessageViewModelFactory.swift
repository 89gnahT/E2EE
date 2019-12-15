//
//  MessageViewModelFactory.swift
//  E2EE
//
//  Created by CPU12015 on 12/4/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MessageViewModelFactory: NSObject {
    class func createViewModel(_ model: MessageModel) -> MessageViewModel{
        var viewModel: MessageViewModel!
        
        switch model.type {
        case .text:
            viewModel = TextMessageViewModel(model: model as! TextMessageModel)
        
        case .image:
            viewModel = ImageMessageViewModel(model: model as! ImageMessageModel)
            
        case .emoji:
            viewModel = EmojiMessageViewModel(model: model as! EmojiMessageModel)
        }                
        
        return viewModel
    }
}

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
    class func viewModel(_ model: MessageModel) -> MessageViewModel{
        var viewModel: MessageViewModel!
        
        if model.type == .text{
            viewModel = TextMessageViewModel(model: model as! TextMessageModel)
        }else if model.type == .image{
            viewModel = ImageMessageViewModel(model: model as! ImageMessageModel)
        }
        
        return viewModel
    }
}

//
//  MessageCellFactory.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class MessageCellFactory: NSObject {
    class func createMessageCell(withMessageViewModel viewModel: BaseMessageViewModel, target: BaseMessageCellDelegate) -> BaseMessageCell{
        var cell: BaseMessageCell!
        
        if let messageViewModel = viewModel as? MessageViewModel{
            switch messageViewModel.model.type {
            case .text:
                cell = TextMessageCell(viewModel: messageViewModel as! TextMessageViewModel)
            
            case .emoji:
                cell = EmojiMessageCell(viewModel: messageViewModel as! EmojiMessageViewModel)
                
            case .image:
                cell = ImagesMessageCell(viewModel: messageViewModel as! ImageMessageViewModel)
            }
        }else
            if let titleViewModel = viewModel as? MessageTitleViewModel{
                cell = MessageTitleCell(viewModel: titleViewModel)
        }
        
        cell.delegate = target
        
        return cell
    }
}

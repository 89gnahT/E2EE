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
            if (viewModel as! MessageViewModel).model.type == .text{
                cell = TextMessageCell(viewModel: messageViewModel as! TextMessageViewModel)
            }else{
                cell = ImagesMessageCell(viewModel: messageViewModel as! ImageMessageViewModel)
            }
        }else{
            
        }
        cell.delegate = target
        
        return cell
    }
}

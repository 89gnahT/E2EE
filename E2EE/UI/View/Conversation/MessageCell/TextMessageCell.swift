//
//  TextMessageCell.swift
//  E2EE
//
//  Created by CPU12015 on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextMessageCell: MessageViewCell {

    public var textViewModel : TextMessageViewModel{
        get{
            return viewModel as! TextMessageViewModel
        }
    }
    
    public var textContentNode : TextContentNode{
        get{
            return contentNode as! TextContentNode
        }
    }
    
    init(viewModel: TextMessageViewModel) {
        
        super.init(viewModel: viewModel)
        
        contentNode = TextContentNode()
        
        reloadData()
    }
    
    override func reloadData() {
        textContentNode.attributedText = textViewModel.textContent
        
        super.reloadData()
    }
   
}

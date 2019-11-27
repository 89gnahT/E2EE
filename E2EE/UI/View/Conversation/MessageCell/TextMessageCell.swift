//
//  TextMessageCell.swift
//  E2EE
//
//  Created by CPU12015 on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextMessageCell: MessageCell {

    public var textViewModel : TextMessageViewModel{
        get{
            return viewModel as! TextMessageViewModel
        }
    }
    
    @objc public var textContentNode : TextContentNode{
        get{
            return contentNode as! TextContentNode
        }
    }
    
    init(viewModel: TextMessageViewModel) {
        
        super.init(viewModel: viewModel)
        
        contentNode = TextContentNode()
        
        reloadData()
        
        textContentNode.addTarget(self, action: #selector(textMessageCellClicked), forControlEvents: .touchUpInside)
    }
    
    override func reloadData() {
        textContentNode.attributedText = textViewModel.textContent
        textContentNode.bubbleImage = textViewModel.bubbleImage
        
        super.reloadData()
    }
   
    @objc func textMessageCellClicked(){
        hideDetails = !hideDetails
    }
}

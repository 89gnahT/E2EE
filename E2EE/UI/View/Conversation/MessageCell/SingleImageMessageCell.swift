//
//  SingleImageMessageCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol SingleImageMessageCellDelegate: MessageCellDelegate {
    
    func messageCell(_ cell : MessageCell, imageContentClicked imageNode : ASImageNode)
    
}

class SingleImageMessageCell: MessageCell {
    public var imageViewModel : ImageMessageViewModel{
        get{
            return viewModel as! ImageMessageViewModel
        }
    }
    
    @objc public var imageContentNode : SingleImageContentNode{
        get{
            return contentNode as! SingleImageContentNode
        }
    }
    
    init(viewModel: ImageMessageViewModel) {
        
        super.init(viewModel: viewModel)
        
        contentNode = SingleImageContentNode()
        
        reloadData()
    }
    
    override func reloadData() {
        imageContentNode.imageURL = imageViewModel.imageURLs[0]
        
        super.reloadData()
    }
    
}

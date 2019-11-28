//
//  ImagesMessageCell.swift
//  E2EE
//
//  Created by CPU12015 on 11/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ImagesMessageCell: MessageCell {
    public var imageViewModel : ImageMessageViewModel{
        get{
            return viewModel as! ImageMessageViewModel
        }
    }
    
    public var imagesContentNode : ImagesContentNode{
        get{
            return contentNode as! ImagesContentNode
        }
    }
    
    init(viewModel: ImageMessageViewModel) {
        
        super.init(viewModel: viewModel)
        
        contentNode = ImagesContentNode()
        
        reloadData()
    }
    
    override func reloadData() {
        imagesContentNode.imageURLs = imageViewModel.imageURLs
        imagesContentNode.isIncomingMessage = imageViewModel.isIncommingMessage
        
        super.reloadData()
    }
}

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
    public var imageViewModel : ImageMessageViewModel
    
    private var imagesContentNode: ImagesContentNode
    
    init(viewModel: ImageMessageViewModel) {
        imageViewModel = viewModel
        imagesContentNode = ImagesContentNode(viewModel: imageViewModel, tapAction: #selector(contentClicked(_:)))
        super.init()
    }
    
    override func setup() {
        super.setup()
        
        updateUI()
    }
    
    override func getViewModel() -> MessageViewModel {
        return imageViewModel
    }
    
    override func updateUI() {
        super.updateUI()
        
        imagesContentNode.updateUI()
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: imagesContentNode)
    }
}

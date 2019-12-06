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
        imagesContentNode = ImagesContentNode(viewModel: imageViewModel)
        super.init()
    }
    
    override func setupContent() {
        
    }
    
    override func getContentNode() -> ContentNode {
        return imagesContentNode
    }
    
    override func didLoad() {
        super.didLoad()

    }
    
    override func updateUIContent() {
         imagesContentNode.updateUI()
    }
    
    override func getViewModel() -> MessageViewModel {
        return imageViewModel
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: imagesContentNode)
    }
}

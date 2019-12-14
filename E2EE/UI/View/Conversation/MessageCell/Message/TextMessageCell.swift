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
    
    private var textContentNode: TextContentNode
    
    public var textViewModel : TextMessageViewModel
    
    init(viewModel: TextMessageViewModel) {
        textViewModel = viewModel
        textContentNode = TextContentNode(viewModel: textViewModel)
        
        super.init()
    }
    
    
    override func setupContent() {
        
    }
    
    override func getContentNode() -> ContentNode {
        return textContentNode
    }
    
    override func didLoad() {
        super.didLoad()
        
        textContentNode.addTarget(self, action: #selector(contentClicked(_:)), forControlEvents: .touchUpInside)
    }
    
    override func getViewModel() -> MessageViewModel {
        return textViewModel
    }
    
    override func updateUIContent() {
        textContentNode.updateUI()
    }
    
    override func updateHighlightContentIfNeed() {
        self.textViewModel.isHighlight = isHighlightContent
        self.textContentNode.updateUI(isHighlightContent)
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: textContentNode)
    }
    
    override func contentClicked(_ contentNode: ASDisplayNode) {
        super.contentClicked(contentNode)
        
        isHideDetails = !isHideDetails
    }
    
}

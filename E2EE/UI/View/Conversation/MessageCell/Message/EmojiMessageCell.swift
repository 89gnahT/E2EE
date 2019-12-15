//
//  EmojiMessageCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/15/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EmojiMessageCell: MessageCell {
    
    private var emojiContentNode: EmojiContentNode
    
    public var emojiViewModel : EmojiMessageViewModel
    
    init(viewModel: EmojiMessageViewModel) {
        emojiViewModel = viewModel
        emojiContentNode = EmojiContentNode(viewModel: emojiViewModel)
        
        super.init()
    }
        
    override func setupContent() {
        
    }
    
    override func getContentNode() -> ContentNode {
        return emojiContentNode
    }
    
    override func didLoad() {
        super.didLoad()
        
        emojiContentNode.addTarget(self, action: #selector(contentClicked(_:)), forControlEvents: .touchUpInside)
    }
    
    override func getViewModel() -> MessageViewModel {
        return emojiViewModel
    }
    
    override func updateUIContent() {
        emojiContentNode.updateUI()
    }
    
    override func updateHighlightContentIfNeed() {
        self.emojiViewModel.isHighlight = isHighlightContent
        self.emojiContentNode.updateUI(isHighlightContent)
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: emojiContentNode)
    }
    
    override func contentClicked(_ contentNode: ASDisplayNode) {
        super.contentClicked(contentNode)
        
        isHideDetails = !isHideDetails
    }
    
}

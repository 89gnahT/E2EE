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

    public var textViewModel : TextMessageViewModel
    
    open var textMessageNode = ASTextNode()

    open var messageInsets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var bubble = Bubble()
    
    init(viewModel: TextMessageViewModel) {
        textViewModel = viewModel
        super.init()
        
        textMessageNode.maximumNumberOfLines = 50
        textMessageNode.style.maxWidth = ASDimension(unit: .points, value: UIScreen.main.bounds.size.width * 0.6)
        
        bubble.addTarget(self, action: #selector(contentClicked(_:)), forControlEvents: .touchUpInside)
        
        updateUI()
    }
    
    override func getViewModel() -> MessageViewModel {
        return textViewModel
    }
    
    override func updateUI() {
        super.updateUI()
        
        textMessageNode.attributedText = textViewModel.textContent
        bubble.image = textViewModel.bubbleImage
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: messageInsets, child: textMessageNode),
                                      background: bubble)
    }
   
    override func contentClicked(_ contentNode: ASDisplayNode) {
        super.contentClicked(contentNode)
        
        hideDetails = !hideDetails
    }
}

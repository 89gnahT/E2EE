//
//  TextContentNode.swift
//  E2EE
//
//  Created by CPU12015 on 12/6/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextContentNode: ContentNode {
    
    public var textViewModel : TextMessageViewModel
    
    open var textMessageNode = ASTextNode()
    
    open var textInsets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var bubble = Bubble()
    
    init(viewModel: TextMessageViewModel, tapAction: Selector? = nil) {
        textViewModel = viewModel
        
        super.init(tapAction: tapAction)
    }
    
    override func setup() {
        super.setup()
        
        textMessageNode.maximumNumberOfLines = 50
        textMessageNode.style.maxWidth = ASDimension(unit: .points, value: UIScreen.main.bounds.size.width * 0.6)
    }
    
    override func didLoad() {
        super.didLoad()

    }
    
    override func updateUI() {
        super.updateUI()
        
        textMessageNode.attributedText = textViewModel.textContent
        bubble.image = textViewModel.bubbleImage
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: textInsets, child: textMessageNode),
                                      background: bubble)
    }
}

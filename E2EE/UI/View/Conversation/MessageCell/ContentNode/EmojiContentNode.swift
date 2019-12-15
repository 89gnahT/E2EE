//
//  EmojiContentNode.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/15/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EmojiContentNode: ContentNode {
    public var emojiViewModel : EmojiMessageViewModel
    
    open var emojiBtnNode = ASButtonNode()
    open var emojiInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var isHighlighted: Bool{
        didSet{
            
        }
    }
    
    init(viewModel: EmojiMessageViewModel) {
        emojiViewModel = viewModel
        
        super.init()
    }
    
    override func setup() {
        super.setup()
        
        emojiBtnNode.titleNode.maximumNumberOfLines = 50
        emojiBtnNode.contentEdgeInsets = emojiInsets
    }
    
    override func getViewModel() -> MessageViewModel {
        return emojiViewModel
    }
    
    override func didLoad() {
        super.didLoad()
        
    }
    
    override func updateUI(_ isHightlight: Bool = false) {
        super.updateUI()
        
        emojiBtnNode.titleNode.attributedText = emojiViewModel.emojiContent
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let maxWidth = isIncommingMessage ? UIScreen.main.bounds.size.width * 0.6 : UIScreen.main.bounds.size.width * 0.7
        emojiBtnNode.style.maxWidth = ASDimension(unit: .points, value: maxWidth)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: emojiBtnNode)
    }
}

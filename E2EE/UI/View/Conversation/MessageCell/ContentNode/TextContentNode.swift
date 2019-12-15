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
    
    open var textBtnNode = ASButtonNode()
    open var textInsets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var isHighlighted: Bool{
        didSet{
            
        }
    }
    
    init(viewModel: TextMessageViewModel) {
        textViewModel = viewModel
        
        super.init()
    }
    
    override func setup() {
        super.setup()
        
        textBtnNode.titleNode.maximumNumberOfLines = 50
        textBtnNode.contentEdgeInsets = textInsets
    }
    
    override func getViewModel() -> MessageViewModel {
        return textViewModel
    }
    
    override func didLoad() {
        super.didLoad()
        
    }
    
    override func updateUI(_ isHightlight: Bool = false) {
        super.updateUI()
        
        textBtnNode.titleNode.attributedText = textViewModel.textContent
        textBtnNode.setBackgroundImage(textViewModel.bubbleImage, for: .normal)    
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let maxWidth = isIncommingMessage ? UIScreen.main.bounds.size.width * 0.6 : UIScreen.main.bounds.size.width * 0.7
        textBtnNode.style.maxWidth = ASDimension(unit: .points, value: maxWidth)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: textBtnNode)
    }
}

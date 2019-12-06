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
  
    init(viewModel: TextMessageViewModel, rootViewController: ChatScreenViewController?) {
        textViewModel = viewModel
        textContentNode = TextContentNode(viewModel: textViewModel)
        
        super.init()
    }
    
    override func setup() {
        super.setup()
        
        updateUI()
    }
    
    override func didLoad() {
        super.didLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        textContentNode.view.addGestureRecognizer(longPressGesture)
        
        textContentNode.addTarget(self, action: #selector(contentClicked(_:)), forControlEvents: .touchUpInside)
    }
    
    override func getViewModel() -> MessageViewModel {
        return textViewModel
    }
    
    override func updateUI() {
        super.updateUI()
    
        textContentNode.updateUI()
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: textContentNode)
    }
   
    override func contentClicked(_ contentNode: ASDisplayNode) {
        super.contentClicked(contentNode)
        
        hideDetails = !hideDetails
    }
}
